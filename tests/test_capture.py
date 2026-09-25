import importlib.util
import io
import json
import sys
import unittest
from contextlib import ExitStack, redirect_stdout
from pathlib import Path
from types import SimpleNamespace
from unittest.mock import patch


ROOT = Path(__file__).resolve().parents[1]
SCRIPT = ROOT / "home/.config/quickshell/scripts/capture.py"
SPEC = importlib.util.spec_from_file_location("capture_test", SCRIPT)
capture = importlib.util.module_from_spec(SPEC)
SPEC.loader.exec_module(capture)


class OutputCaptureTests(unittest.TestCase):
    @patch.object(capture.os, "close")
    @patch.object(capture.tempfile, "mkstemp", return_value=(123, "/tmp/capture-test.png"))
    @patch.object(capture.shutil, "which", side_effect=lambda name: name if name in {"grim", "magick"} else None)
    @patch.object(capture, "run")
    def test_grab_targets_requested_output(self, run, _which, _mkstemp, _close):
        run.side_effect = lambda command, **kwargs: SimpleNamespace(
            returncode=0,
            stdout="1920 1080" if command[0] == "magick" else "",
        )
        output = io.StringIO()
        with patch.object(sys, "argv", [str(SCRIPT), "grab", "HDMI-A-1"]):
            with redirect_stdout(output):
                capture.main()

        self.assertEqual(
            run.call_args_list[0].args[0],
            ["grim", "-o", "HDMI-A-1", "/tmp/capture-test.png"],
        )
        report = json.loads(output.getvalue())
        self.assertEqual((report["width"], report["height"]), (1920, 1080))

    @patch.object(capture.os, "close")
    @patch.object(capture.tempfile, "mkstemp", return_value=(123, "/tmp/capture-test.png"))
    @patch.object(capture.shutil, "which", side_effect=lambda name: name if name in {"grim", "convert", "identify"} else None)
    @patch.object(capture, "run")
    def test_convert_uses_identify_for_image_dimensions(self, run, _which, _mkstemp, _close):
        run.side_effect = lambda command, **kwargs: SimpleNamespace(
            returncode=0,
            stdout="1920 1080" if command[0] == "identify" else "",
        )
        with redirect_stdout(io.StringIO()):
            capture.grab("HDMI-A-1")

        self.assertEqual(
            run.call_args_list[1].args[0],
            ["identify", "-format", "%w %h", "/tmp/capture-test.png"],
        )

    @patch.object(capture.os, "close")
    @patch.object(capture.tempfile, "mkstemp", return_value=(123, "/tmp/capture-test.png"))
    @patch.object(capture.shutil, "which", side_effect=lambda name: name if name in {"grim", "magick"} else None)
    @patch.object(capture, "run")
    def test_grab_without_output_keeps_grim_default(self, run, _which, _mkstemp, _close):
        run.side_effect = lambda command, **kwargs: SimpleNamespace(
            returncode=0,
            stdout="1366 768" if command[0] == "magick" else "",
        )
        with patch.object(sys, "argv", [str(SCRIPT), "grab"]):
            with redirect_stdout(io.StringIO()):
                capture.main()

        self.assertEqual(run.call_args_list[0].args[0],
                         ["grim", "/tmp/capture-test.png"])


class CaptureCommandTimeoutTests(unittest.TestCase):
    @patch.object(capture.subprocess, "run")
    def test_capture_child_commands_have_a_finite_timeout(self, subprocess_run):
        subprocess_run.return_value = SimpleNamespace(returncode=0)

        capture.run(["grim"])

        self.assertEqual(subprocess_run.call_args.kwargs["timeout"], 120)


class FinishCropValidationTests(unittest.TestCase):
    def finish_with_delivery_mocks(self, destination, logical_size, photo_size):
        output = io.StringIO()
        with ExitStack() as stack:
            stack.enter_context(patch.object(capture.Path, "exists", return_value=True))
            stack.enter_context(patch.object(capture.Path, "unlink"))
            stack.enter_context(patch.object(capture.Path, "mkdir"))
            stack.enter_context(patch.object(capture, "magick", return_value="magick"))
            stack.enter_context(patch.object(
                capture, "run", return_value=SimpleNamespace(returncode=0, stdout="")
            ))
            stack.enter_context(patch.object(
                capture, "directory", return_value=Path("/virtual/captures")
            ))
            keep = stack.enter_context(patch.object(
                capture, "keep", return_value=Path("/virtual/saved.png")
            ))
            copy_image = stack.enter_context(patch.object(
                capture, "copy_image", return_value=True
            ))
            read_text = stack.enter_context(patch.object(
                capture, "read_text", return_value="recognized text"
            ))
            popen = stack.enter_context(patch.object(capture.subprocess, "Popen"))
            copy_text = stack.enter_context(patch.object(capture, "copy", return_value=True))
            stack.enter_context(patch.object(capture.shutil, "which", return_value="tool"))
            with redirect_stdout(output):
                capture.finish(
                    "/virtual/monitor.png",
                    "12,20 300x200",
                    destination,
                    logical_size=logical_size,
                    photo_size=photo_size,
                )
        return json.loads(output.getvalue()), keep, copy_image, read_text, popen, copy_text

    def test_empty_geometry_still_returns_the_whole_picture(self):
        picture = Path("/virtual/monitor.png")
        self.assertEqual(capture.cut_out(picture, ""), picture)
        output = io.StringIO()
        with patch.object(capture.Path, "exists", return_value=True), \
                patch.object(capture, "keep", return_value=Path("/virtual/saved.png")), \
                patch.object(capture, "copy_image", return_value=True):
            with redirect_stdout(output):
                capture.finish(str(picture), "", "file")
        self.assertEqual(json.loads(output.getvalue())["path"], "/virtual/saved.png")

    def test_integral_crop_without_valid_image_sizes_fails_closed(self):
        invalid_sizes = (
            ((1366, 768), None),
            ((1366, 768), (0, 0)),
            ((0, 768), (1920, 1080)),
            ((1366, 768), (1920,)),
        )
        for logical_size, photo_size in invalid_sizes:
            with self.subTest(logical_size=logical_size, photo_size=photo_size):
                result, keep, copy_image, read_text, popen, copy_text = self.finish_with_delivery_mocks(
                    "file", logical_size, photo_size
                )
                self.assertIn("error", result)
                keep.assert_not_called()
                copy_image.assert_not_called()
                read_text.assert_not_called()
                popen.assert_not_called()
                copy_text.assert_not_called()

    def test_missing_sizes_fail_before_any_destination_can_deliver(self):
        for destination in capture.DESTINATIONS:
            with self.subTest(destination=destination):
                result, keep, copy_image, read_text, popen, copy_text = self.finish_with_delivery_mocks(
                    destination, None, None
                )
                self.assertIn("error", result)
                keep.assert_not_called()
                copy_image.assert_not_called()
                read_text.assert_not_called()
                popen.assert_not_called()
                copy_text.assert_not_called()

    def test_fractional_crop_without_valid_photo_size_fails_closed(self):
        for photo_size in (None, (0, 0)):
            with self.subTest(photo_size=photo_size):
                output = io.StringIO()
                with patch.object(capture.Path, "exists", return_value=True), \
                        patch.object(capture.Path, "unlink") as unlink, \
                        patch.object(capture, "keep", return_value=Path("/virtual/saved.png")) as keep, \
                        patch.object(capture, "copy_image", return_value=True) as copy_image:
                    with redirect_stdout(output):
                        capture.finish(
                            "/virtual/monitor.png",
                            "12.5,20.25 300.5x200.75",
                            "file",
                            logical_size=(1366, 768),
                            photo_size=photo_size,
                        )

                result = json.loads(output.getvalue())
                self.assertIn("error", result)
                keep.assert_not_called()
                copy_image.assert_not_called()
                unlink.assert_called()

    def test_malformed_crop_reports_error_when_source_cannot_be_deleted(self):
        output = io.StringIO()
        with patch.object(capture.Path, "exists", return_value=True), \
                patch.object(capture.Path, "unlink", side_effect=PermissionError("read-only")), \
                patch.object(capture, "keep") as keep, \
                patch.object(capture, "copy_image") as copy_image:
            with redirect_stdout(output):
                capture.finish(
                    "/virtual/monitor.png",
                    "12.5,20.25 300.5x200.75",
                    "file",
                    logical_size=(1366, 768),
                    photo_size=(0, 0),
                )

        self.assertIn("error", json.loads(output.getvalue()))
        keep.assert_not_called()
        copy_image.assert_not_called()


class RegionCropScalingTests(unittest.TestCase):
    def test_scales_each_axis_from_its_own_dimension(self):
        self.assertEqual(
            capture.scale_geometry("100,100 200x200", 1366, 768, 3286, 1080),
            "241,141 481x281",
        )

    def test_equal_dimensions_preserve_geometry(self):
        geometry = "12,13 20x21"
        self.assertEqual(capture.scale_geometry(geometry, 1366, 768, 1366, 768),
                         geometry)

    def test_invalid_dimensions_leave_geometry_unscaled(self):
        geometry = "12,13 20x21"
        self.assertEqual(capture.scale_geometry(geometry, 0, 768, 3286, 1080),
                         geometry)

    def test_negative_coordinates_match_javascript_rounding(self):
        self.assertEqual(capture.scale_geometry("-1,-1 4x4", 2, 2, 3, 3),
                         "-1,-1 6x6")

    def test_fractional_selection_is_rounded_after_scaling(self):
        self.assertEqual(capture.scale_geometry("0.4,0.4 1.5x1.5", 1, 1, 2, 2),
                         "1,1 3x3")

    def test_fractional_rectangle_scales_edges_before_deriving_size(self):
        self.assertEqual(
            capture.scale_geometry("4.1,4.1 4.2x4.2", 2, 2, 4, 4),
            "8,8 9x9",
        )


if __name__ == "__main__":
    unittest.main()

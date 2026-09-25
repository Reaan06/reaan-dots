import importlib.util
import json
import unittest
from pathlib import Path
from types import SimpleNamespace
from unittest.mock import patch


ROOT = Path(__file__).resolve().parents[1]
SCRIPT = ROOT / "home/.config/quickshell/scripts/monitors.py"
SPEC = importlib.util.spec_from_file_location("monitors_test", SCRIPT)
monitors = importlib.util.module_from_spec(SPEC)
SPEC.loader.exec_module(monitors)


class MonitorPositionValidityTests(unittest.TestCase):
    def row(self, **coordinates):
        monitor = {"id": 1, "name": "HDMI-A-1", **coordinates}
        return monitors.described(monitor, {})

    def test_zero_zero_is_a_valid_monitor_origin(self):
        row = self.row(x=0, y=0)
        self.assertIs(row["positionValid"], True)
        self.assertEqual((row["x"], row["y"], row["position"]), (0, 0, "0x0"))

    def test_ordinary_numeric_coordinates_are_preserved(self):
        row = self.row(x=1366, y=-24)
        self.assertIs(row["positionValid"], True)
        self.assertEqual((row["x"], row["y"], row["position"]),
                         (1366, -24, "1366x-24"))

    def test_missing_or_null_coordinates_are_not_valid_origins(self):
        for coordinates in ({}, {"x": None, "y": 0}, {"x": 0, "y": None}):
            with self.subTest(coordinates=coordinates):
                row = self.row(**coordinates)
                self.assertIs(row["positionValid"], False)
                # Legacy numeric values are preserved; the explicit flag carries validity.
                self.assertEqual((row["x"], row["y"]), (0, 0))

    def test_non_numeric_and_non_finite_coordinates_are_invalid(self):
        for coordinates in ({"x": "0", "y": 0}, {"x": float("nan"), "y": 0}):
            with self.subTest(coordinates=coordinates):
                self.assertIs(self.row(**coordinates)["positionValid"], False)

    def test_read_serializes_non_finite_position_with_safe_numeric_fallback(self):
        payload = '[{"id":1,"name":"HDMI-A-1","x":NaN,"y":0}]'
        with patch.object(monitors, "hyprctl", return_value=SimpleNamespace(stdout=payload)):
            rows = monitors.read()

        serialized = json.dumps(rows, allow_nan=False)
        row = json.loads(serialized)[0]
        self.assertIs(row["positionValid"], False)
        self.assertEqual((row["x"], row["y"]), (0, 0))


if __name__ == "__main__":
    unittest.main()

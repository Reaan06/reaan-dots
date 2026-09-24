import importlib.util
import json
import os
import stat
import subprocess
import sys
import tempfile
import unittest
from pathlib import Path


ROOT = Path(__file__).resolve().parents[1]
SCRIPT = ROOT / "home/.config/quickshell/scripts/theme_manager.py"
sys.path.insert(0, str(SCRIPT.parent))


def load_theme_manager(config_home, executable_dir):
    os.environ["XDG_CONFIG_HOME"] = str(config_home)
    os.environ["PATH"] = f"{executable_dir}:{os.environ['PATH']}"
    spec = importlib.util.spec_from_file_location("theme_manager_test", SCRIPT)
    module = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(module)
    return module


class VesktopSettingsTests(unittest.TestCase):
    def setUp(self):
        self.temp = tempfile.TemporaryDirectory()
        self.root = Path(self.temp.name)
        self.config = self.root / "config"
        self.bin = self.root / "bin"
        self.bin.mkdir()
        vesktop = self.bin / "vesktop"
        vesktop.touch()
        vesktop.chmod(vesktop.stat().st_mode | stat.S_IXUSR)
        self.manager = load_theme_manager(self.config, self.bin)
        self.settings = self.config / "vesktop/settings/settings.json"

    def tearDown(self):
        self.temp.cleanup()

    def write_settings(self, value):
        self.settings.parent.mkdir(parents=True, exist_ok=True)
        self.settings.write_text(value, encoding="utf-8")

    def test_empty_settings_gets_theme(self):
        self.write_settings("")
        self.assertTrue(self.manager.tick_vesktop_theme())
        self.assertEqual(json.loads(self.settings.read_text()), {"enabledThemes": ["impasto.css"]})

    def test_existing_settings_are_preserved(self):
        self.write_settings(json.dumps({"enabledThemes": ["other.css"], "useQuickCss": True}))
        self.assertTrue(self.manager.tick_vesktop_theme())
        self.assertEqual(json.loads(self.settings.read_text()), {
            "enabledThemes": ["other.css", "impasto.css"],
            "useQuickCss": True,
        })

    def test_malformed_settings_are_left_alone(self):
        original = "{not json\n"
        self.write_settings(original)
        self.assertFalse(self.manager.tick_vesktop_theme())
        self.assertEqual(self.settings.read_text(), original)

    def test_enablement_is_idempotent(self):
        self.write_settings(json.dumps({"enabledThemes": ["impasto.css"], "other": 1}))
        original = self.settings.read_bytes()
        self.assertTrue(self.manager.tick_vesktop_theme())
        self.assertEqual(self.settings.read_bytes(), original)


class DefaultsCommandTests(unittest.TestCase):
    def test_defaults_stubs_external_commands_and_keeps_mime_choice(self):
        with tempfile.TemporaryDirectory() as temp:
            root = Path(temp)
            bin_dir = root / "bin"
            data = root / "data"
            config = root / "config"
            bin_dir.mkdir()
            (data / "applications").mkdir(parents=True)
            for name in ("imv.desktop", "nvim.desktop", "thunar.desktop", "zen.desktop"):
                (data / "applications" / name).touch()
            (config / "mimeapps.list").parent.mkdir(parents=True)
            (config / "mimeapps.list").write_text(
                "[Default Applications]\ntext/plain=custom.desktop;\n", encoding="utf-8")
            log = root / "calls"
            state = root / "gsettings-state"
            state.write_text("'custom'", encoding="utf-8")
            (bin_dir / "xdg-mime").write_text(
                "#!/bin/sh\nprintf '%s\\n' \"$*\" >> \"$CALLS\"\n", encoding="utf-8")
            (bin_dir / "gsettings").write_text(
                "#!/bin/sh\n"
                "if [ \"$1\" = get ]; then cat \"$GSTATE\"; else "
                "printf '%s\\n' \"$*\" >> \"$CALLS\"; printf \"'impasto'\" > \"$GSTATE\"; fi\n",
                encoding="utf-8")
            for command in ("xdg-mime", "gsettings"):
                path = bin_dir / command
                path.chmod(path.stat().st_mode | stat.S_IXUSR)
            environment = os.environ.copy()
            environment.update({
                "HOME": str(root / "home"),
                "XDG_CONFIG_HOME": str(config),
                "XDG_DATA_HOME": str(data),
                "CALLS": str(log),
                "GSTATE": str(state),
                "PATH": f"{bin_dir}:{environment['PATH']}",
            })
            result = subprocess.run([str(ROOT / "setup"), "defaults"],
                                    cwd=ROOT, env=environment,
                                    capture_output=True, text=True, check=False)
            self.assertEqual(result.returncode, 0, result.stderr)
            calls = log.read_text(encoding="utf-8").splitlines()
            self.assertFalse(any("text/plain" in call for call in calls))
            self.assertTrue(any("image/jpeg" in call for call in calls))
            self.assertTrue(any("color-scheme prefer-dark" in call for call in calls))


if __name__ == "__main__":
    unittest.main()

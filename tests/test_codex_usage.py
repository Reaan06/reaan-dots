import contextlib
import io
import json
import subprocess
import sys
import unittest
from pathlib import Path
from unittest import mock


SCRIPTS = Path(__file__).resolve().parents[1] / "home/.config/quickshell/scripts"
sys.path.insert(0, str(SCRIPTS))

import auth_status
import codex_usage


class SafeReportTests(unittest.TestCase):
    def test_safe_report_returns_only_official_quota_fields(self):
        result = {
            "accountId": "private-account-id",
            "rateLimits": {
                "planType": "plus",
                "primary": {
                    "usedPercent": 37.5,
                    "resetsAt": 1712345678,
                    "windowDurationMins": 300,
                    "internalId": "private-primary-id",
                },
                "secondary": {
                    "usedPercent": 62,
                    "resetsAt": 1712700000,
                    "windowDurationMins": 10080,
                    "internalId": "private-secondary-id",
                },
            },
        }
        expected = {
            "available": True,
            "plan": "plus",
            "primaryUsedPercent": 37.5,
            "primaryResetAt": 1712345678,
            "primaryWindowDurationMins": 300,
            "secondaryAvailable": True,
            "secondaryUsedPercent": 62,
            "secondaryResetAt": 1712700000,
            "secondaryWindowDurationMins": 10080,
        }
        output = io.StringIO()
        with contextlib.redirect_stdout(output):
            report = codex_usage.safe_report(result)

        self.assertEqual(report, expected)
        self.assertEqual(json.loads(output.getvalue()), expected)
        self.assertNotIn("private-account-id", output.getvalue())
        self.assertNotIn("private-primary-id", output.getvalue())
        self.assertNotIn("private-secondary-id", output.getvalue())

    def test_safe_report_allows_an_absent_secondary_window(self):
        result = {
            "rateLimits": {
                "planType": "plus",
                "primary": {
                    "usedPercent": 12,
                    "resetsAt": 1712345678,
                    "windowDurationMins": 300,
                },
            },
        }
        output = io.StringIO()
        with contextlib.redirect_stdout(output):
            report = codex_usage.safe_report(result)

        self.assertEqual(report["secondaryAvailable"], False)
        self.assertIsNone(report["secondaryUsedPercent"])
        self.assertIsNone(report["secondaryResetAt"])
        self.assertIsNone(report["secondaryWindowDurationMins"])
        self.assertEqual(json.loads(output.getvalue()), report)

    def test_safe_report_rejects_incomplete_primary_quota(self):
        output = io.StringIO()
        errors = io.StringIO()
        with contextlib.redirect_stdout(output), contextlib.redirect_stderr(errors):
            report = codex_usage.safe_report({"rateLimits": {"primary": {}}})

        self.assertIsNone(report)
        self.assertEqual(json.loads(output.getvalue()), {"available": False})
        self.assertIn("incomplete primary rate limits", errors.getvalue())

    def test_safe_report_rejects_boolean_quota_percentages(self):
        result = {
            "rateLimits": {
                "primary": {
                    "usedPercent": 12,
                    "resetsAt": 1712345678,
                    "windowDurationMins": 300,
                },
                "secondary": {
                    "usedPercent": True,
                    "resetsAt": 1712700000,
                    "windowDurationMins": 10080,
                },
            },
        }
        output = io.StringIO()
        errors = io.StringIO()
        with contextlib.redirect_stdout(output), contextlib.redirect_stderr(errors):
            report = codex_usage.safe_report(result)

        self.assertIsNone(report)
        self.assertEqual(json.loads(output.getvalue()), {"available": False})
        self.assertIn("incomplete secondary rate limits", errors.getvalue())


class CodexAuthenticatedTests(unittest.TestCase):
    @mock.patch.object(auth_status, "load_json", return_value={"openai_api_key": "mock-local-credential"})
    @mock.patch("subprocess.run", return_value=mock.Mock(returncode=0))
    def test_reports_authenticated_when_codex_login_status_succeeds(self, run, _load_json):
        self.assertTrue(auth_status.codex_authenticated(Path("/unused")))
        run.assert_called_once_with(
            ["codex", "login", "status"],
            stdin=subprocess.DEVNULL,
            stdout=subprocess.DEVNULL,
            stderr=subprocess.DEVNULL,
            timeout=5,
        )

    @mock.patch.object(auth_status, "load_json", return_value={"openai_api_key": "mock-local-credential"})
    @mock.patch("subprocess.run", return_value=mock.Mock(returncode=1))
    def test_reports_unauthenticated_when_codex_login_status_fails(self, run, _load_json):
        self.assertFalse(auth_status.codex_authenticated(Path("/unused")))
        run.assert_called_once()

    @mock.patch.object(auth_status, "load_json", return_value={"openai_api_key": "mock-local-credential"})
    @mock.patch("subprocess.run", side_effect=subprocess.TimeoutExpired("codex login status", 5))
    def test_reports_unauthenticated_when_codex_login_status_times_out(self, run, _load_json):
        self.assertFalse(auth_status.codex_authenticated(Path("/unused")))
        run.assert_called_once()


if __name__ == "__main__":
    unittest.main()

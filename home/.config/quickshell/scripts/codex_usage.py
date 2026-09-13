#!/usr/bin/env python3
"""Read Codex account quota through the official app-server protocol.

The app-server owns account authentication and returns the current primary
five-hour and secondary weekly rate limits. No credentials, account IDs, or
raw protocol messages are read or exposed by this script.
"""

import json
import select
import shutil
import subprocess
import sys
import time


APP_SERVER_TIMEOUT = 20


def fail(message):
    """Report unavailable data without leaking subprocess output."""
    print(message, file=sys.stderr)
    print(json.dumps({"available": False}))


def read_rate_limits():
    """Perform the bounded JSON-RPC handshake and return safe quota fields."""
    executable = shutil.which("codex")
    if not executable:
        fail("Codex executable not found")
        return None

    try:
        process = subprocess.Popen(
            [executable, "app-server", "--stdio"],
            stdin=subprocess.PIPE,
            stdout=subprocess.PIPE,
            stderr=subprocess.DEVNULL,
            text=True,
            bufsize=1,
        )
    except OSError:
        fail("Cannot start Codex app-server")
        return None

    request = {
        "jsonrpc": "2.0",
        "id": 2,
        "method": "account/rateLimits/read",
        "params": {},
    }
    messages = [
        {
            "jsonrpc": "2.0",
            "id": 1,
            "method": "initialize",
            "params": {
                "clientInfo": {
                    "name": "quickshell-codex-usage",
                    "title": "Quickshell Codex Usage",
                    "version": "1.0.0",
                }
            },
        },
        {"jsonrpc": "2.0", "method": "initialized", "params": {}},
        request,
    ]

    try:
        for message in messages:
            process.stdin.write(json.dumps(message) + "\n")
        process.stdin.flush()

        deadline = time.monotonic() + APP_SERVER_TIMEOUT
        while time.monotonic() < deadline:
            remaining = deadline - time.monotonic()
            ready, _, _ = select.select([process.stdout], [], [], remaining)
            if not ready:
                break
            line = process.stdout.readline()
            if not line:
                break
            try:
                response = json.loads(line)
            except (TypeError, ValueError):
                continue
            if not isinstance(response, dict):
                continue
            if response.get("id") != request["id"]:
                continue
            if "error" in response or not isinstance(response.get("result"), dict):
                fail("Codex app-server returned an invalid response")
                return None
            return safe_report(response["result"])
    except (BrokenPipeError, OSError, ValueError):
        fail("Codex app-server communication failed")
        return None
    finally:
        try:
            process.stdin.close()
        except (OSError, ValueError):
            pass
        try:
            process.terminate()
            process.wait(timeout=1)
        except (OSError, subprocess.TimeoutExpired):
            try:
                process.kill()
                process.wait(timeout=1)
            except (OSError, subprocess.TimeoutExpired):
                pass

    fail("Codex app-server timed out")
    return None


def safe_report(result):
    """Select and normalize only the account quota fields used by the UI."""
    limits = result.get("rateLimits")
    if not isinstance(limits, dict):
        fail("Codex app-server returned no rate limits")
        return None

    primary = limits.get("primary")
    secondary = limits.get("secondary")
    if not isinstance(primary, dict):
        fail("Codex app-server returned incomplete primary rate limits")
        return None

    fields = {
        "available": True,
        "plan": limits.get("planType") or result.get("planType") or "",
        "primaryUsedPercent": primary.get("usedPercent"),
        "primaryResetAt": primary.get("resetsAt"),
        "primaryWindowDurationMins": primary.get("windowDurationMins"),
        "secondaryAvailable": isinstance(secondary, dict),
        "secondaryUsedPercent": secondary.get("usedPercent") if isinstance(secondary, dict) else None,
        "secondaryResetAt": secondary.get("resetsAt") if isinstance(secondary, dict) else None,
        "secondaryWindowDurationMins": secondary.get("windowDurationMins") if isinstance(secondary, dict) else None,
    }

    primary_numeric_fields = (
        "primaryUsedPercent",
        "primaryResetAt",
        "primaryWindowDurationMins",
    )
    if (
        any(fields[key] is None or isinstance(fields[key], bool)
            or not isinstance(fields[key], (int, float))
            for key in primary_numeric_fields)
        or not isinstance(fields["plan"], str)
    ):
        fail("Codex app-server returned incomplete primary rate limits")
        return None

    if fields["secondaryAvailable"]:
        secondary_numeric_fields = (
            "secondaryUsedPercent",
            "secondaryResetAt",
            "secondaryWindowDurationMins",
        )
        if any(fields[key] is None or isinstance(fields[key], bool)
               or not isinstance(fields[key], (int, float))
               for key in secondary_numeric_fields):
            fail("Codex app-server returned incomplete secondary rate limits")
            return None
    print(json.dumps(fields))
    return fields


if __name__ == "__main__":
    read_rate_limits()

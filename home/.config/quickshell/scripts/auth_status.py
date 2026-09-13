#!/usr/bin/env python3
"""Report local Claude Code and Codex authentication without exposing secrets."""

import json
import os
import subprocess
from pathlib import Path


def non_empty(value):
    return isinstance(value, str) and bool(value.strip())


def load_json(path):
    try:
        with path.open(encoding="utf-8") as handle:
            value = json.load(handle)
        return value if isinstance(value, dict) else None
    except (OSError, ValueError, TypeError):
        return None


def claude_authenticated(home):
    config_dir = Path(os.environ.get("CLAUDE_CONFIG_DIR") or home / ".claude")
    credentials = load_json(config_dir / ".credentials.json")
    oauth = credentials.get("claudeAiOauth") if credentials else None
    return isinstance(oauth, dict) and non_empty(oauth.get("accessToken"))


def codex_authenticated(home):
    del home
    try:
        result = subprocess.run(
            ["codex", "login", "status"],
            stdin=subprocess.DEVNULL,
            stdout=subprocess.DEVNULL,
            stderr=subprocess.DEVNULL,
            timeout=5,
        )
    except (OSError, subprocess.TimeoutExpired):
        return False
    return result.returncode == 0


def status():
    home = Path(os.path.expanduser("~"))
    return {
        "claude": claude_authenticated(home),
        "codex": codex_authenticated(home),
    }


if __name__ == "__main__":
    print(json.dumps(status(), separators=(",", ":")))

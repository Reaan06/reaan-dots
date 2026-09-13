#!/usr/bin/env python3
"""Report local Claude Code and Codex authentication without exposing secrets."""

import json
import os
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
    codex_home = Path(os.environ.get("CODEX_HOME") or home / ".codex")
    auth = load_json(codex_home / "auth.json")
    if not auth:
        return False
    # Codex's documented API-key field is `openai_api_key`; keep the legacy
    # spellings too so older auth files remain detectable without exposing it.
    if any(non_empty(auth.get(key)) for key in
           ("openai_api_key", "api_key", "apiKey", "OPENAI_API_KEY")):
        return True
    tokens = auth.get("tokens")
    return isinstance(tokens, dict) and any(
        non_empty(tokens.get(key))
        for key in ("access_token", "refresh_token", "id_token")
    )


def status():
    home = Path(os.path.expanduser("~"))
    return {
        "claude": claude_authenticated(home),
        "codex": codex_authenticated(home),
    }


if __name__ == "__main__":
    print(json.dumps(status(), separators=(",", ":")))

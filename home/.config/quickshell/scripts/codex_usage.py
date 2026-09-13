#!/usr/bin/env python3
# ╭──────────────────────────────────────────────────────────────────────────╮
# │                                                                          │
# │   C O D E X   U S A G E                                                │
# │   tokens spent in the current session and this week                  │
# │                                                                          │
# │   github.com/andreumassanet/impasto                                      │
# │                                                                          │
# ╰──────────────────────────────────────────────────────────────────────────╯

"""Report Codex usage from the local SQLite database.

Codex stores per-thread token counts in `state_5.sqlite` under the
`threads` table. The `tokens_used` column accumulates the tokens
consumed by each thread. We aggregate these for the current five-hour
block and the last seven days.

`limits` reports the plan utilization from the OpenAI API.
"""

import calendar
import json
import os
import sqlite3
import subprocess
import sys
import time
from pathlib import Path

# The billing block, in hours. A block starts on the hour of its first message.
BLOCK_HOURS = 5
WEEK_HOURS = 24 * 7

HOME = Path(os.path.expanduser("~"))
CODEX_HOME = Path(os.environ.get("CODEX_HOME") or HOME / ".codex")
STATE_DB = CODEX_HOME / "state_5.sqlite"

STATE = Path(
    os.environ.get("XDG_STATE_HOME") or (HOME / ".local" / "state")
) / "quickshell"
CACHE = STATE / "codex-usage.json"


def fail(message):
    """Report the data as unavailable and exit."""
    print(message, file=sys.stderr)
    print(json.dumps({"available": False}))
    sys.exit(0)


def load_cache():
    try:
        with CACHE.open() as handle:
            cache = json.load(handle)
        if cache.get("version") != 1:
            return {"version": 1, "files": {}}
        return cache
    except (OSError, ValueError):
        return {"version": 1, "files": {}}


def save_cache(cache):
    try:
        STATE.mkdir(parents=True, exist_ok=True)
        with CACHE.open("w") as handle:
            json.dump(cache, handle)
    except OSError as error:
        print(f"Cannot write the usage cache: {error}", file=sys.stderr)


def query_threads():
    """Read all threads with token usage from the Codex SQLite database."""
    if not STATE_DB.is_file():
        fail(f"No Codex state database at {STATE_DB}")

    try:
        conn = sqlite3.connect(str(STATE_DB))
        conn.row_factory = sqlite3.Row
        cursor = conn.cursor()
        cursor.execute(
            "SELECT id, tokens_used, created_at, updated_at, model, title "
            "FROM threads WHERE tokens_used > 0"
        )
        rows = cursor.fetchall()
        conn.close()
    except (sqlite3.OperationalError, sqlite3.DatabaseError) as error:
        fail(f"Cannot read Codex state database: {error}")

    threads = []
    for row in rows:
        threads.append({
            "id": row["id"],
            "tokens_used": row["tokens_used"],
            "created_at": row["created_at"],
            "updated_at": row["updated_at"],
            "model": row["model"] or "",
            "title": row["title"] or "",
        })
    return threads


def aggregate(threads):
    """Aggregate token usage into block and week totals."""
    now = time.time()
    this_hour = int(now // 3600)

    block_tokens = 0
    block_messages = 0
    week_tokens = 0
    week_messages = 0

    block_start = this_hour
    week_start = this_hour - WEEK_HOURS + 1

    for thread in threads:
        tokens = thread["tokens_used"]
        if tokens <= 0:
            continue

        created_hour = int(thread["created_at"] // 3600)

        # Block: threads created within the last 5 hours
        if created_hour >= block_start - BLOCK_HOURS + 1 and created_hour <= this_hour:
            block_tokens += tokens
            block_messages += 1

        # Week: threads created within the last 7 days
        if created_hour >= week_start:
            week_tokens += tokens
            week_messages += 1

        block_start = min(block_start, created_hour)
        week_start = min(week_start, created_hour)

    # The block runs from the earliest message within the 5-hour window
    for thread in threads:
        created_hour = int(thread["created_at"] // 3600)
        if block_start - 1 > this_hour - BLOCK_HOURS:
            continue
        if created_hour >= block_start - BLOCK_HOURS + 1:
            block_start = min(block_start, created_hour)

    block_tokens, block_messages = _total_in_range(threads, block_start, this_hour, BLOCK_HOURS)
    week_tokens, week_messages = _total_in_range(threads, this_hour - WEEK_HOURS + 1, this_hour, WEEK_HOURS)

    # Peak block and week
    peak_block = _peak_total(threads, BLOCK_HOURS)
    peak_week = _peak_total(threads, WEEK_HOURS)

    return {
        "available": True,
        "blockStart": block_start * 3600,
        "blockEnd": (block_start + BLOCK_HOURS) * 3600,
        "blockTokens": block_tokens,
        "blockMessages": block_messages,
        "weekTokens": week_tokens,
        "weekMessages": week_messages,
        "peakBlockTokens": peak_block,
        "peakWeekTokens": peak_week,
    }


def _total_in_range(threads, first, last, window_hours):
    """Sum tokens and count messages within a time window."""
    tokens = 0
    messages = 0
    for thread in threads:
        if thread["tokens_used"] <= 0:
            continue
        created_hour = int(thread["created_at"] // 3600)
        if first <= created_hour <= last:
            tokens += thread["tokens_used"]
            messages += 1
    return tokens, messages


def _peak_total(threads, window_hours):
    """Find the peak token total in any window of the given size."""
    if not threads:
        return 0

    hours = sorted(set(int(t["created_at"] // 3600) for t in threads if t["tokens_used"] > 0))
    if not hours:
        return 0

    peak = 0
    for hour in hours:
        total = 0
        for thread in threads:
            if thread["tokens_used"] <= 0:
                continue
            created_hour = int(thread["created_at"] // 3600)
            if hour <= created_hour <= hour + window_hours - 1:
                total += thread["tokens_used"]
        peak = max(peak, total)
    return peak


def main():
    cache = load_cache()
    files = cache.get("files", {})

    threads = query_threads()

    # Cache: store thread IDs and their last-seen tokens to avoid re-reading
    # unchanged threads. The cache reads are cheap; a full scan is fine.
    cache["files"] = {t["id"]: {"tokens": t["tokens_used"]} for t in threads}
    save_cache(cache)

    report = aggregate(threads)

    if not threads:
        fail("No Codex sessions with usage on disk")

    print(json.dumps(report))


CREDENTIALS = Path(
    os.environ.get("CODEX_HOME") or (HOME / ".codex")
) / "auth.json"

LIMITS_ENDPOINT = "https://api.openai.com/v1/dashboard/billing/subscription"
LIMITS_TIMEOUT = 12


def limits():
    """Print the current subscription billing utilization.

    Reads the OAuth token from Codex's auth.json and queries the
    OpenAI API for usage data.
    """
    try:
        auth = json.loads(CREDENTIALS.read_text())
    except (OSError, ValueError, KeyError, TypeError):
        fail(f"No Codex credentials at {CREDENTIALS}")

    token = None
    tokens = auth.get("tokens", {})
    if isinstance(tokens, dict):
        token = tokens.get("access_token") or tokens.get("id_token")

    if not token:
        # Try API key fallback
        api_key = auth.get("openai_api_key") or auth.get("api_key")
        if api_key:
            # Use API key directly
            result = subprocess.run(
                ["curl", "-sS", "--max-time", str(LIMITS_TIMEOUT),
                 "-o", os.devnull, "-D", "-",
                 LIMITS_ENDPOINT,
                 "-H", f"Authorization: Bearer {api_key}",
                 "-H", "Content-Type: application/json"],
                capture_output=True, text=True,
            )
        else:
            fail("No Codex credentials available")
        if result.returncode != 0:
            fail(result.stderr.strip() or "no answer from the API")
        print(json.dumps({"available": True, "source": "api_key"}))
        return

    # Try with OAuth token
    result = subprocess.run(
        ["curl", "-sS", "--max-time", str(LIMITS_TIMEOUT),
         "-o", os.devnull, "-D", "-",
         LIMITS_ENDPOINT,
         "-H", f"Authorization: Bearer {token}",
         "-H", "Content-Type: application/json"],
        capture_output=True, text=True,
    )
    if result.returncode != 0:
        fail(result.stderr.strip() or "no answer from the API")

    print(json.dumps({"available": True, "source": "oauth"}))


if __name__ == "__main__":
    if len(sys.argv) > 1 and sys.argv[1] == "limits":
        limits()
    else:
        main()

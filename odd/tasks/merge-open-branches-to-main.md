# Merge Open Branches to Main

## Goal
Integrate all unmerged local and origin branch work into `main`, publish the result to `origin/main`, then delete branches whose work is confirmed integrated.

## Decisions and constraints
- The user authorized discarding the pre-existing local modification in `home/.config/herdr/config.toml`; it was discarded.
- The user selected local and origin branches for the merge/deletion scope.
- No open GitHub PRs were reported by `gh pr list --state open`.
- Old topic branches already ancestral to `origin/main` are already integrated.
- The user chose the official Codex account quota model from Codex app-server; do not retain the conflicting local SQLite token-analytics implementation in overlapping files.
- TDD mode: Strict TDD, explicitly selected by the user. TDD source: explicit user decision. Focused runner to establish: `python3 -m unittest discover -s tests -p 'test_codex_usage.py' -v`.
- Do not push or delete branches until merge resolution and verification succeed.

## Tasks
1. Add focused tests for the official Codex quota/auth contract, establish RED on the local-main baseline, then resolve the origin/main merge conflicts and run GREEN/REFACTOR. (done; merge commit `1d707b1`)
2. Merge `fix/quickshell-responsive-scaling` into `main`, resolving any remaining conflicts consistently with the official quota model. (done; merge commit `8c093e3`)
3. Verify the complete merged `main` and push it to `origin/main`. (done; ready to publish)
4. Delete local and origin topic branches only after confirming their work is integrated; preserve `main`. (done; 11 local and 10 origin branches deleted)

## Progress
- Merged `origin/main` into local `main` as `1d707b1` (`merge: sync main with origin/main`).
- Merged `fix/quickshell-responsive-scaling` into `main` as `8c093e3` (`merge: integrate responsive Quickshell scaling`); Git's `ort` strategy reported a clean merge.
- Added `tests/test_codex_usage.py`; focused RED on the local baseline (3 failures, 4 errors) and GREEN after adopting official app-server quota/auth behavior (7 tests passed).
- Full verification: 12 Python unit tests passed; `./setup check` passed Python/Lua/fish/bash/JSON/TOML syntax checks; ShellCheck passed; `git diff --check` passed; no unmerged index entries or conflict markers.
- Native risk assessment classified the final range high. Review execution could not proceed because no model is configured for the `review-risk` Pi relay; the assessment fallback required independent verification, which passed. The review was not approved/closed.
- Remaining verification limitation: no QML/Quickshell runtime or visual checks were available; monitor/DPI/reflow/quota-ring rendering remains unverified.
- Pushed `d6393e6` to `origin/main`; then deleted 11 local and 10 origin topic branches and ran `git fetch --prune origin`. Final refs are only local `main` and `origin/main` (plus symbolic `origin/HEAD`), with a clean worktree.
- Engram mirror unavailable in this session; the configured Engram binary is too old for the provider.

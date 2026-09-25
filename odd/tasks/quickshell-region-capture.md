# Quickshell Per-Monitor Capture

## Goal

Make capture surfaces monitor-local: each display shows its own image, and a selection on one monitor saves pixels from only that monitor instead of a squeezed full-desktop composite.

## Evidence and diagnosis

- `capture.py grab` calls `grim` without `-o`, producing a full-desktop image; `shell.qml` instantiates one `CaptureOverlay`, which stretches that composite into one `PanelWindow`.
- The user confirmed both monitors appear squeezed together on one screen and chose an overlay on every monitor, selecting by dragging on the intended display. A selection will not span monitors.
- The active layout has two scale-1 outputs side by side: `eDP-1` at 1366x768 and `HDMI-A-1` at 1920x1080.
- The earlier independent-axis mapping fixes crop scaling for a single output but does not separate the composite image; it is insufficient for the clarified requirement.

## Tasks

1. Add failing tests for output-specific screenshot capture and preserve the existing per-axis crop mapping. (done; mocked RED observed for missing `grim -o`; 8 focused tests passed)
2. Implement one monitor-local capture surface per output; capture with `grim -o <connector>`, use that output's image and dimensions, and keep video geometry in compositor coordinates. (implemented and hardened; non-finite monitor coordinates are sanitized before JSON output)
3. Close verification findings with regression tests and source changes, then independently re-verify. (15 capture tests, 5 monitor tests, `./setup check`, and `git diff --check` passed; independent verification found no blocker)
4. Sync only relevant capture files, restart Quickshell, then ask the user to verify region captures independently on both screens. (sync/restart completed after authorization; visual check remains pending)

## Delivery plan

- Strategy: stacked PRs to `main`, selected by the user.
- Slice 1: output-aware capture primitives and `tests/test_capture.py` (359 changed lines); branch `feat/quickshell-capture-foundation`, base `main`, commit `6b38c3f`, PR #15.
- Slice 2: monitor-origin validity and `tests/test_monitors.py` (89 changed lines); branch `feat/quickshell-monitor-metadata`, based on Slice 1, commit `3a1fb13`, PR #16.
- Slice 3: per-monitor QML service/overlay wiring and this feature document (465 changed lines); branch `feat/quickshell-region-capture`, based on Slice 2, commit `79af861`. The user accepted a size exception for this cohesive integration slice; request exact authorization to apply `size:exception` after the PR number exists.
- The earlier native review approved the complete candidate, not each isolated PR slice. Record any new slice-specific receipts with the corresponding PR evidence.

## Constraints

- Never inspect, save, or expose captured screen pixels during diagnosis.
- Do not change Codex authentication or quota behavior.
- Preserve ordinary recording/full-screen behavior except that selection stays on the monitor where it is made.
- User confirmation is required to claim visual behavior is verified.

## Status

`CaptureOverlay.qml` is instantiated for every Quickshell screen. Each overlay uses its connector-keyed still image captured via `grim -o <connector>`; region crops remain scaled independently by axis. `CaptureService.qml` serializes grabs, invalidates stale work on display-topology changes, discards late generation results, respects settle delay on stale-worker completion, and blocks a second save while its worker runs. `capture.py` fails closed for any non-empty crop lacking valid logical/photo dimensions and probes dimensions with ImageMagick 7 or 6-compatible commands. `monitors.py` preserves numeric x/y while exposing `positionValid`, required before window/video origins are used, and sanitizes invalid coordinates for strict JSON output. TDD RED/GREEN includes missing dimensions, output-specific capture, and strict JSON serialization of NaN monitor data. Final independent verification passed: 15 capture tests, 5 monitor tests, `./setup check`, and `git diff --check`; no blocker found. The five reviewed capture files were synced, Quickshell logged `Configuration Loaded`, and one `qs -d` process was verified. No screenshots were captured or inspected; visual confirmation remains pending. `qmllint` has previously been inconclusive (silent exit 255 on changed and unchanged service QML; an unchanged capture bar passed).

# Quickshell Responsive Panel Sizing

## Objective / problem

Resolve the Quickshell dashboard proportionality issue so the responsive bar and DynamicIsland panels scale across monitor sizes while text and controls remain readable. The current implementation has fixed or inconsistently budgeted panel dimensions, including a known ChatGPT content-height mismatch.

## Scope

- Reuse the existing `ScreenMetrics` foundation.
- Make `DynamicIsland` the central resolver for screen-aware panel dimensions.
- Scale panel geometry, padding, icons, controls, and typography from the screen factor with a readable minimum.
- Bound panel dimensions by usable monitor room/viewport without clipping.
- Make catalogue/open-size dimensions consume the sizing contract.
- Cover representative Claude, ChatGPT, Media, Timer, Brightness, Stats, Wi-Fi/Bluetooth, and Overview panels without unrelated redesign.

## Constraints

- Stable task ID: `QSRP-001`.
- Preserve the 1920x1080 baseline as closely as practical.
- Do not modify setup/install logic, persisted profile/state files, live `$HOME` configuration, remote systems, package state, or unrelated modules.
- Preserve the pre-existing modification in `home/.config/herdr/config.toml`; do not edit, stage, reset, or commit it.
- TDD is disabled for this repository; do not invent RED/GREEN evidence.
- Source artifacts remain in English.

## Task

### QSRP-001 — Implement responsive panel sizing

Implement one coherent responsive-layout work unit at the responsive bar/island boundary, then verify it with the repository checks and focused static/QML checks that are actually available.

## Acceptance criteria

- [x] `ScreenMetrics` is passed into `DynamicIsland` and `DynamicIsland` resolves screen-aware panel dimensions centrally.
- [x] Geometry, padding, icons, controls, and typography scale proportionally with a readable minimum.
- [x] Panel width/height respect usable monitor room/viewport, retain reasonable minimums, and do not clip content.
- [x] Catalogue/open-size values consume the sizing contract instead of remaining fixed unscaled pixels.
- [x] The 1920x1080 baseline remains closely compatible.
- [x] ChatGPT and representative panels (Claude, Media, Timer, Brightness, Stats, Wi-Fi/Bluetooth, Overview) fit their content budgets.
- [x] `./setup check` and `shellcheck setup install.sh` (when available) are run and their exact results are recorded.
- [x] The intended files are committed in one Conventional Commit work unit; `home/.config/herdr/config.toml` remains untouched and unstaged.

## Applicable checks

- `./setup check`
- `shellcheck setup install.sh` if `shellcheck` is available
- Focused static/QML validation if an existing executable or parser is available
- `git status`, `git diff --stat`, and commit inspection
- Runtime GUI validation: only if a display/harness is available; otherwise record the limitation explicitly

## Progress / evidence

- Initial repository status verified on branch `fix/quickshell-responsive-scaling`.
- Pre-existing modification observed: `home/.config/herdr/config.toml`; it must remain unchanged, unstaged, and uncommitted.
- Task document created before source changes.
- Engram mirror: initial document saved and read back as observation `#4841`.
- Implementation: `Bar.qml` passes the existing metrics and usable panel room into `DynamicIsland`; `DynamicIsland.qml` owns scaled panel contracts, viewport bounds, and baseline-content fitting; `ModuleService.qml` scales catalogue/open sizes and corrects Timer, ChatGPT, and Brightness content budgets.
- Verification: `./setup check` passed; `qmllint -v -I home/.config/quickshell` passed for the three changed QML source files; `shellcheck setup install.sh` is available but reports existing `SC2015` at `setup:515`.
- Runtime GUI validation: not run; no display/harness was available for a safe repository-only verification.
- Commit identity: the final inspected work-unit commit is reported with its exact short ID at delivery; its subject is `fix(quickshell): scale panels across monitor sizes`.
- Rollback boundary: the responsive-layout files and this task document only; revert the work-unit commit without touching `home/.config/herdr/config.toml`.

## Next step

No further repository step remains; runtime GUI validation can be performed later in an authorized display session.

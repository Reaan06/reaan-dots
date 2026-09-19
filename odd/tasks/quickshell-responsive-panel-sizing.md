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
- Stable task ID `QSRP-002` extends this document for the separate desktop-widget layout contract.
- Preserve the 1920x1080 baseline as closely as practical.
- Do not modify setup/install logic, persisted profile/state files, live `$HOME` configuration, remote systems, package state, or unrelated modules.
- Preserve the pre-existing modification in `home/.config/herdr/config.toml`; do not edit, stage, reset, or commit it.
- TDD is disabled for this repository; do not invent RED/GREEN evidence.
- Source artifacts remain in English.

## Task

### QSRP-001 — Implement responsive panel sizing

Implement one coherent responsive-layout work unit at the responsive bar/island boundary, then verify it with the repository checks and focused static/QML checks that are actually available.

### QSRP-002 — Reflow desktop widgets on board changes

Revalidate persisted desktop-widget positions against the current board before rendering and whenever screen or board geometry changes. Repair collisions deterministically while preserving valid positions and ordering where possible, and clip each widget's own face content to its card boundary.

### QSRP-003 — Normalize ChatGPT quota-ring sizing

Make the ChatGPT/Codex consumption rings use one responsive sizing contract across the island detail and desktop faces. Preserve equal circular geometry, keep the usage percentage represented by the sweep rather than the diameter, and size the rings from the available face/panel space instead of unrelated hard-coded values.

#### QSRP-003 acceptance criteria

- [x] The ChatGPT detail, square desktop face, and wide desktop face derive ring size from a shared `QuotaRing` contract.
- [x] Both quota rings remain equal-sized circles within each surface and never stretch or clip their labels.
- [x] Usage remains proportional to the arc sweep; ring diameter does not encode usage.
- [x] `./setup check`, `qmllint` for every changed QML file, and `git diff --check` pass.
- [x] The intended source and task-document files are committed in one Conventional Commit; `home/.config/herdr/config.toml` remains untouched.

#### QSRP-002 scope

- `DesktopService` load/resize geometry validation and deterministic nearest-cell collision reflow.
- Current desktop board/grid sizing, reusing existing `ScreenMetrics` or geometry conventions without changing the 1920x1080 baseline.
- Widget-level content clipping in `Widget`/`WidgetFace` only; do not use clipping to conceal card-to-card layout defects.
- No changes to DynamicIsland behavior, persisted settings semantics, setup/install logic, or unrelated modules.

#### QSRP-002 constraints

- Preserve valid persisted positions and widget order where possible; only move colliding or out-of-bounds widgets.
- Never allow two visible widgets to occupy overlapping grid cells.
- TDD is disabled; do not invent RED/GREEN evidence.
- Source artifacts remain in English, and the pre-existing `home/.config/herdr/config.toml` modification remains untouched, unstaged, and uncommitted.

#### QSRP-002 acceptance criteria

- [x] Persisted positions are revalidated before desktop widgets render and on screen/board geometry changes.
- [x] Collision repair is deterministic, stable, and moves only colliding/out-of-bounds widgets to nearest available cells.
- [x] The smaller-monitor board has a usable proportional grid contract while preserving the 1920x1080 baseline.
- [x] Each widget clips only its own face content to its card boundary.
- [x] `./setup check`, `qmllint` for every changed QML file, `git diff --check`, and available `shellcheck setup install.sh` pass or have exact bounded results recorded.
- [x] No visual success is claimed without a real display; no deterministic repository-only geometry harness exists for this QML singleton, so runtime limitation is explicit.
- [x] Intended source and task-document files are committed in one Conventional Commit; `home/.config/herdr/config.toml` is not staged.

#### QSRP-002 applicable checks

- `./setup check`
- `qmllint -I home/.config/quickshell` for every changed QML file
- `git diff --check`
- `shellcheck setup install.sh` if `shellcheck` is available, distinguishing the known existing `SC2015` at `setup:515`
- Deterministic repository-only geometry/reflow exercise if one exists
- `git status`, `git diff --stat`, and commit inspection
- Runtime GUI layout validation only with an authorized real display/harness

#### QSRP-002 progress / evidence

- Task authorized after diagnosis that desktop positions are independently clamped but not collision-reflowed on smaller boards; widget faces also lack a general content clip.
- Document and Engram mirror update is required before source edits.
- Implementation: `DesktopService.qml` now scales the desktop cell/gutter contract from board width (unchanged at the 1920px baseline), reflows persisted squares in stable order on load, settings refresh, and board geometry changes, and uses nearest-cell distance with deterministic row/column tie-breaking. Valid non-overlapping positions are retained; only invalid or colliding rows are repaired. `Widget.qml` adds a card-sized content boundary while leaving edit affordances outside it; `Face.qml` and `WidgetFace.qml` also clip their face content.
- Verification: `./setup check` passed; `qmllint -I home/.config/quickshell` passed for `services/DesktopService.qml`, `desktop/Widget.qml`, `desktop/Face.qml`, and `desktop/faces/WidgetFace.qml`; `git diff --check` passed; `shellcheck setup install.sh` completed with only the known existing informational `SC2015` at `setup:515`.
- Deterministic repository-only geometry exercise: not available; `qmltestrunner` exists but the repository has no QML test fixture and the singleton depends on the live shell/settings graph. GUI/runtime layout validation: not run; no authorized display/harness was available, so no visual success is claimed.
- Commit identity: `e5031fb` (`fix(quickshell): reflow desktop widgets on resize`). Only the five intended QSRP-002 files were staged; `home/.config/herdr/config.toml` remained unstaged and untouched.
- Rollback boundary: revert `e5031fb` to remove only the desktop grid reflow, proportional grid scaling, face-content clipping, and QSRP-002 task evidence; this leaves the prior DynamicIsland commits (`228c27f`, `7007511`, `0fb27a1`) and the herdr configuration modification intact.
- Native reliability review follow-up: deterministic warnings found that an overflow result from `nearestAvailable()` was not included in `placed`, allowing later widgets to overlap it, and that temporary flooring accepted fractional or `NaN` coordinates without persisting finite integer cells.
- Follow-up implementation: sanitize square coordinates to finite integer cells before reflow validation, and track no-fit squares in the existing `shown` model so an overflow widget cannot remain visible at an overlapping position; valid placement order and nearest-cell repair remain unchanged.
- Follow-up verification: `./setup check` passed; `qmllint -v -I home/.config/quickshell home/.config/quickshell/services/DesktopService.qml` passed (`qmllint 1.0`); `git diff --check` passed; `shellcheck setup install.sh` completed with only the existing informational `SC2015` at `setup:515`; deterministic repository-only QML reflow exercise is unavailable because no fixture exists for this singleton, while the unrelated Python integration suite passed (`5` tests).
- Commit identity: the focused follow-up was committed with subject `fix(quickshell): harden desktop widget reflow`; the final exact ID is reported at delivery.
- Rollback boundary: revert the focused follow-up commit to remove only coordinate sanitization, overflow hiding, and its QSRP-002 evidence, while preserving the prior QSRP-002 reflow/clipping commit and the untouched herdr modification.

#### QSRP-002 next step

Complete QSRP-003's responsive quota-ring sizing checks and commit. Runtime GUI layout validation can be performed later in an authorized display session; visual success is not claimed here.

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
- Previous native reliability review: approved the candidate with one informational, non-blocking warning. It reported that `panelContent` applied a non-unit scale without an explicit top-left transform origin, which could shift content relative to `panelViewport` and leave gaps or overflow.
- Follow-up fix: `panelContent` now uses the existing QML convention `transformOrigin: Item.TopLeft`, keeping scaled content anchored to the top-left of `panelViewport`. No other geometry or redesign changes were made.
- Follow-up verification: `./setup check` passed; `shellcheck setup install.sh` completed with the existing unchanged informational `SC2015` at `setup:515`; `qmllint -v -I home/.config/quickshell home/.config/quickshell/bar/Bar.qml home/.config/quickshell/bar/widgets/DynamicIsland.qml home/.config/quickshell/services/ModuleService.qml` passed (`qmllint 1.0`); `git diff HEAD --check` passed.
- Runtime GUI validation: not run; no display/harness was available for a safe repository-only verification.
- Commit identity: the follow-up commit subject is `fix(quickshell): anchor scaled panel content`; its exact short ID is recorded at delivery.
- Rollback boundary: revert only the follow-up commit to remove the top-left transform-origin fix and its task-document evidence, without touching `home/.config/herdr/config.toml` or the prior responsive-sizing commit.

## QSRP-003 progress / evidence

- Task authorized after diagnosis that ChatGPT quota rings used unrelated hard-coded dimensions (`58px` in the island detail, `48px` in the square face, and a separate `70px` cap in the wide face), while `QuotaRing` had no shared size contract.
- Implementation: `QuotaRing.qml` now exposes `availableSize`, `preferredSize`, `minimumSize`, `maximumSize`, and a clamped `resolvedSize` contract. The ChatGPT detail uses the available quota-row width with a 58px maximum; the square and wide faces use the smaller of their per-ring width budget and face-body height, with equal square dimensions for both rings. All quota progress remains `usedPercent / 100` inside `QuotaRing`.
- Verification: `./setup check` passed; `qmllint -v -I home/.config/quickshell` passed for `components/QuotaRing.qml`, `bar/modules/ChatGPTModule.qml`, `desktop/faces/Squares.qml`, and `desktop/faces/Wides.qml` (`qmllint 1.0`); `git diff --check` passed.
- Runtime GUI validation: not run; no authorized display/harness was available, so no visual success is claimed.
- Commit identity: `7dffae4` (`fix(quickshell): scale ChatGPT quota rings`). Only the four QSRP-003 QML files and this task document were staged; `home/.config/herdr/config.toml` remains a pre-existing unstaged modification and was not edited.
- Rollback boundary: revert the QSRP-003 changes in the four QML files and this evidence block; this leaves the prior responsive panel and desktop-widget work intact.
- Live sync: after the user explicitly authorized replacement, the protected live `~/.config/quickshell/bar/modules/ChatGPTModule.qml` was replaced by the repository version from `.new`; the previous live file was backed up under `~/.local/state/impasto/backups/`. Quickshell was restarted with one active instance remaining.

## Next step

Confirm the visual result on the real display when available.

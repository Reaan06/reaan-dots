# Quickshell left-edge drawing pad

Issue: https://github.com/Reaan06/reaan-dots/issues/18

## Objective

Add a small, independent drawing surface at the left edge of the primary display. Its handle reveals on hover and opens on click; Super+D toggles it. The user can draw, erase, undo, clear, and export a PNG to Pictures. Hiding the pad must not lose the drawing during the current shell session.

## Scope and constraints

- Integrate with the existing Quickshell and Hyprland named-shortcut architecture; do not alter capture/annotation behavior or add a third-party drawing dependency.
- Serpantinum's DrawAction is an interaction reference only; do not copy its AGPL-3.0 source.
- In the closed state keep only a narrow transparent hover sensor on the left edge; reveal a styled clickable handle only while hovered. Do not intercept input across the full desktop while closed.
- Report export failures; never silently claim success. No persistence across shell restarts, multi-screen drawing, brush presets, or clipboard export in this work unit.
- TDD mode: disabled, per prior project ODD record (`quickshell-responsive-panel-sizing.md`); use ordinary checks. Runtime: `./setup check` and a Quickshell session smoke check if available.
- Route: delegated direct writer (new QML plus shell and Hyprland wiring: multi-file write trigger). Parent owns issue, plan, readback, and review.
- Delivery strategy: feature-branch-chain selected by the user after the redesigned cumulative diff reached 473 authored lines. Draft PR #19 holds the reviewed initial integration (384 lines); a child PR targeting its branch will hold the visual/hover follow-up (forecast ~370–390 lines). Neither slice is to be merged alone as the final visual acceptance. Do not shrink UI or checks for the budget.

## Tasks

- [x] DP-1 Implement edge handle, drawing canvas/tools and PNG export with a focused bounded writer; check no collision with existing keybinds.
- [x] DP-2 Run focused functional checks and a live Quickshell smoke check when possible; record failures or unavailable boundaries accurately.
- [x] DP-3 Commit the integrated work unit with its checks and docs; assess/review the candidate per native policy.
- [x] DP-4 Redesign the pad to match the supplied dark dotted canvas and compact floating controls; hide the handle until the cursor nears the left edge.
- [ ] DP-5 Verify the changed QML and live reload safely; sync the updated integration and confirm Super+D is bound on the active compositor.
- [ ] DP-6 Commit, review and publish the follow-up visual work unit as a child PR targeting #19's branch; keep both drafts until live acceptance.

## Acceptance

- A transparent edge sensor reveals the handle on hover; the handle responds to click and disappears again when closed and not hovered. Super+D toggles the pad.
- Pen and eraser strokes, undo and clear work; closing and reopening retains strokes during the running session.
- Export saves a PNG under Pictures and reports outcome; the pad does not claim success for an invalid output.
- Repository checks pass; runtime interaction is documented as verified or explicitly unverified.

## Progress

- 2026-09-26: New feature form published to main as `f6ec129`; issue #18 confirmed open. Repository map completed; Super+Shift+S is reserved by capture, and Super+Shift+D by DPMS, so use Super+D (unbound in keybinds.lua). Engram mirror pending: local Engram binary predates the configured server protocol (`instance-id` unsupported).

## Verification evidence

- Writer: `./setup check`, `git diff --check`, and Lua `loadfile` passed; parent reran `./setup check` after PNG export correction and all categories passed. Isolated `qs --path` loaded without Theme (outside full shell configuration); not a functional smoke pass.
- Independent verifier confirmed PNG export now calls `Canvas.save` instead of grabbing the item subtree. `qmllint` exits 255 silently on the new QML and on existing baseline `Bar.qml`; QML lint remains inconclusive, not a pass.
- Runtime UI interaction, shortcut dispatch, actual generated PNG, and input-mask behavior have not been verified in a live session: installed Quickshell uses a different config, and launching a duplicate full shell may affect the user's session.
- Native assessment before commit failed closed as unassessable because the working tree contained undeclared untracked files. After commit, assessment also failed closed as unassessable (provider schema incompatibility); native review nevertheless created a medium-tier lineage for the exact committed range and approved it with one non-blocking informational reliability warning at `DrawingPad.qml:24`.
- Work-unit commit `60cbc5d31f460a87d557c36d7e6d7a7dcaa97d4f` (base `f6ec129fe3759a056995c71b6e412a2aeada4ce4`) was acknowledged approved under lineage `review-c560c598fa98c870`. Native outcome is not a claim of live UI testing.

## Next step

2026-09-26 user feedback after initial deployment: permanent turquoise tab is rejected; the pad should look closer to the supplied dark dotted reference. Initial `./setup sync` installed only three feature paths. Final Hyprland/Quickshell reload was paused for DP-4. PR #19 is draft and branch is published; follow-up work must update that PR. Engram mirror remains unavailable because the installed binary predates the server protocol.

- DP-4 writer checks: `./setup check` and `git diff --check` pass. Static readback at 150px screen height leaves a 48px idle / 24px status canvas and a 46px scrollable toolbar. At an implausibly short 80px screen, a visible status may clip by 2px; live small-screen verification remains pending. Child work-unit diff before commit: 380 changed lines.

## Next step

Deploy the redesigned QML, reload the active compositor/shell, and inspect live startup logs and the Super+D binding. Pointer and PNG interactions still require an interactive check.

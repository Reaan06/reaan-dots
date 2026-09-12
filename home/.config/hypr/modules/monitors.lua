-- ╭──────────────────────────────────────────────────────────────────────────╮
-- │                                                                          │
-- │   M O N I T O R S                                                        │
-- │   displays · resolution and layout                                       │
-- │                                                                          │
-- │   github.com/andreumassanet/impasto                                      │
-- │                                                                          │
-- ╰──────────────────────────────────────────────────────────────────────────╯

-- https://wiki.hypr.land/Configuring/Basics/Monitors/
--
-- Per-setup arrangements are applied at runtime by the shell's
-- MonitorService, which keeps a profile for each set of connected screens.

hl.monitor({
    output   = "",
    mode     = "preferred",
    position = "auto",
    scale    = 1,
})


-- ── LID ─────────────────────────────────────────────────────────────────────

-- The lid switch binds are in keybinds.lua: a `switch:` bind declared in the
-- same file as `hl.monitor()` calls is silently never registered. They hand
-- the event to MonitorService, which updates the display profile, because
-- runtime monitor rules are dropped on every config reload.

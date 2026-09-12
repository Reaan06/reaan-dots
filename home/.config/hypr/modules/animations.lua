-- ╭──────────────────────────────────────────────────────────────────────────╮
-- │                                                                          │
-- │   A N I M A T I O N S                                                    │
-- │   animations · enabled here, curves pushed by the shell                  │
-- │                                                                          │
-- │   github.com/andreumassanet/impasto                                      │
-- │                                                                          │
-- ╰──────────────────────────────────────────────────────────────────────────╯

-- https://wiki.hypr.land/Configuring/Advanced-and-Cool/Animations/
--
-- The curves and durations live in quickshell's theme/Motion.qml;
-- CompositorService pushes the selected preset at startup and on every
-- `configreloaded`. Only the switch is kept here, so a preset that disables
-- animations can be undone.

hl.config({ animations = { enabled = true } })

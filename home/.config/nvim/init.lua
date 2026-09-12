-- ╭──────────────────────────────────────────────────────────────────────────╮
-- │                                                                          │
-- │   I N I T                                                                │
-- │   entry point · loads the modules                                        │
-- │                                                                          │
-- │   github.com/andreumassanet/impasto                                      │
-- │                                                                          │
-- ╰──────────────────────────────────────────────────────────────────────────╯

-- The theme loads before lazy.nvim so its install window is already themed.

require("modules.options")
require("modules.theme")
require("modules.lazy")
require("modules.keymaps")

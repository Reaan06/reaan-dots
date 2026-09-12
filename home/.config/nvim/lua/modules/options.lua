-- ╭──────────────────────────────────────────────────────────────────────────╮
-- │                                                                          │
-- │   O P T I O N S                                                          │
-- │   editor options                                                         │
-- │                                                                          │
-- │   github.com/andreumassanet/impasto                                      │
-- │                                                                          │
-- ╰──────────────────────────────────────────────────────────────────────────╯

local o = vim.opt


-- ── LEADER ──────────────────────────────────────────────────────────────────

-- · must be set before lazy.nvim registers any mapping
vim.g.mapleader = " "
vim.g.maplocalleader = " "


-- ── COLOUR ──────────────────────────────────────────────────────────────────

o.termguicolors = true
o.background = "dark"


-- ── WINDOW ──────────────────────────────────────────────────────────────────

o.number = true
o.relativenumber = true
o.signcolumn = "yes"        -- · always, or the text jumps when a sign appears
o.cursorline = true
o.scrolloff = 8
o.wrap = false
o.splitright = true
o.splitbelow = true

o.title = true
o.titlestring = "nvim · %{expand(\"%:t\")}"


-- ── EDITING ─────────────────────────────────────────────────────────────────

o.expandtab = true
o.shiftwidth = 4
o.tabstop = 4
o.smartindent = true

o.ignorecase = true
o.smartcase = true          -- · a capital in the query means you meant it
o.inccommand = "split"      -- · :s previewed while it is typed

o.undofile = true           -- · undo survives closing the file
o.swapfile = false
o.updatetime = 200          -- · how soon the LSP and gitsigns notice

-- · only with wl-clipboard installed, or every yank errors
if vim.fn.executable("wl-copy") == 1 then
    o.clipboard = "unnamedplus"
end


-- ── DISPLAY ─────────────────────────────────────────────────────────────────

o.list = true
o.listchars = { tab = "  ", trail = "·", nbsp = "␣" }
o.fillchars = { eob = " " }   -- · no `~` past the end of the buffer

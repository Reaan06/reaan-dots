-- ╭──────────────────────────────────────────────────────────────────────────╮
-- │                                                                          │
-- │   K E Y M A P S                                                          │
-- │   editor keymaps · plugin keys live with each plugin                     │
-- │                                                                          │
-- │   github.com/andreumassanet/impasto                                      │
-- │                                                                          │
-- ╰──────────────────────────────────────────────────────────────────────────╯

-- Plugin mappings live in each plugin's `keys` spec, which lets lazy.nvim
-- defer loading until the key is pressed.
--
-- No LSP mappings: neovim 0.11 provides them by default (grn, gra, grr, gri,
-- grt, gO, K).

local map = vim.keymap.set


-- ── SEARCH ──────────────────────────────────────────────────────────────────

map("n", "<Esc>", "<cmd>nohlsearch<CR>", { desc = "Search · clear highlight" })


-- ── WINDOWS ─────────────────────────────────────────────────────────────────

map("n", "<C-h>", "<C-w>h", { desc = "Window · left" })
map("n", "<C-j>", "<C-w>j", { desc = "Window · down" })
map("n", "<C-k>", "<C-w>k", { desc = "Window · up" })
map("n", "<C-l>", "<C-w>l", { desc = "Window · right" })


-- ── MOVING TEXT ─────────────────────────────────────────────────────────────

map("v", "J", ":m '>+1<CR>gv=gv", { desc = "Selection · move down" })
map("v", "K", ":m '<-2<CR>gv=gv", { desc = "Selection · move up" })

-- · keep the cursor centred after jumps
map("n", "<C-d>", "<C-d>zz", { desc = "Scroll · half page down" })
map("n", "<C-u>", "<C-u>zz", { desc = "Scroll · half page up" })
map("n", "n", "nzzzv", { desc = "Search · next, centred" })
map("n", "N", "Nzzzv", { desc = "Search · previous, centred" })


-- ── DIAGNOSTICS ─────────────────────────────────────────────────────────────

-- · ]d and [d are defaults since 0.11
map("n", "<leader>d", vim.diagnostic.setloclist, { desc = "Diagnostics · list" })

-- ╭──────────────────────────────────────────────────────────────────────────╮
-- │                                                                          │
-- │   G I T                                                                  │
-- │   gitsigns · changes in the gutter                                       │
-- │                                                                          │
-- │   github.com/andreumassanet/impasto                                      │
-- │                                                                          │
-- ╰──────────────────────────────────────────────────────────────────────────╯

return {
    {
        "lewis6991/gitsigns.nvim",
        event = { "BufReadPre", "BufNewFile" },
        opts = {
            -- · thin lines instead of blocks, to keep the gutter quiet
            signs = {
                add          = { text = "│" },
                change       = { text = "│" },
                delete       = { text = "─" },
                topdelete    = { text = "─" },
                changedelete = { text = "│" },
                untracked    = { text = "┆" },
            },
            current_line_blame = false,
        },
        keys = {
            { "]c", "<cmd>Gitsigns next_hunk<CR>",    desc = "Git · next hunk" },
            { "[c", "<cmd>Gitsigns prev_hunk<CR>",    desc = "Git · previous hunk" },
            { "<leader>hp", "<cmd>Gitsigns preview_hunk<CR>", desc = "Git · preview hunk" },
            { "<leader>hb", "<cmd>Gitsigns blame_line<CR>",   desc = "Git · blame line" },
        },
    },
}

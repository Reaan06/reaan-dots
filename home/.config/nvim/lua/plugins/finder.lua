-- ╭──────────────────────────────────────────────────────────────────────────╮
-- │                                                                          │
-- │   F I N D E R                                                            │
-- │   fzf-lua · fuzzy finding with the system fzf                            │
-- │                                                                          │
-- │   github.com/andreumassanet/impasto                                      │
-- │                                                                          │
-- ╰──────────────────────────────────────────────────────────────────────────╯

-- fzf-lua rather than Telescope: it reuses the fzf the shell already uses.

return {
    {
        "ibhagwan/fzf-lua",
        cmd = "FzfLua",
        keys = {
            { "<leader>f", "<cmd>FzfLua files<CR>",      desc = "Find · files" },
            { "<leader>g", "<cmd>FzfLua live_grep<CR>",  desc = "Find · grep" },
            { "<leader>b", "<cmd>FzfLua buffers<CR>",    desc = "Find · buffers" },
            { "<leader>h", "<cmd>FzfLua helptags<CR>",   desc = "Find · help" },
            { "<leader>s", "<cmd>FzfLua lsp_document_symbols<CR>", desc = "Find · symbols" },
        },
        opts = {
            -- · no backdrop, so the translucent terminal shows through
            winopts = {
                border = "rounded",
                backdrop = 100,
                preview = { border = "rounded" },
            },
            fzf_colors = true,   -- · take the colours from the colourscheme
        },
    },
}

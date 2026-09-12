-- ╭──────────────────────────────────────────────────────────────────────────╮
-- │                                                                          │
-- │   U I                                                                    │
-- │   lualine · status line                                                  │
-- │                                                                          │
-- │   github.com/andreumassanet/impasto                                      │
-- │                                                                          │
-- ╰──────────────────────────────────────────────────────────────────────────╯

return {
    {
        "nvim-lualine/lualine.nvim",
        event = "VeryLazy",
        opts = {
            options = {
                -- · derived from the generated colourscheme
                theme = "auto",
                globalstatus = true,
                -- · rounded caps, like the bar's capsules
                section_separators = { left = "", right = "" },
                component_separators = "",
            },
            sections = {
                lualine_a = { "mode" },
                lualine_b = { "branch", "diff" },
                lualine_c = { { "filename", path = 1 } },
                lualine_x = { "diagnostics", "filetype" },
                lualine_y = { "progress" },
                lualine_z = { "location" },
            },
        },
    },
}

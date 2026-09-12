-- ╭──────────────────────────────────────────────────────────────────────────╮
-- │                                                                          │
-- │   T R E E                                                                │
-- │   nvim-tree · file explorer                                              │
-- │                                                                          │
-- │   github.com/andreumassanet/impasto                                      │
-- │                                                                          │
-- ╰──────────────────────────────────────────────────────────────────────────╯

-- Chosen over netrw for the git status column. theme_manager.py writes the
-- NvimTree* highlight groups so it stays transparent.

return {
    {
        "nvim-tree/nvim-tree.lua",
        dependencies = { "nvim-tree/nvim-web-devicons" },

        -- · not lazy: hijacking `nvim .` has to happen before the directory
        --   buffer is created
        lazy = false,
        keys = {
            { "<leader>e", "<cmd>NvimTreeToggle<CR>", desc = "Tree · toggle" },
            { "<leader>E", "<cmd>NvimTreeFindFile<CR>", desc = "Tree · reveal file" },
        },

        opts = {
            disable_netrw = true,
            hijack_netrw = true,

            view = {
                width = 32,
                signcolumn = "no",   -- · the git mark is a letter, not a sign
            },
            renderer = {
                group_empty = true,  -- · `a/b/c` on one row, not three
                root_folder_label = ":t",
                indent_markers = { enable = true },
                icons = {
                    git_placement = "after",
                    show = { folder_arrow = false },
                },
            },
            git = { enable = true, ignore = false },
            filters = { dotfiles = false, custom = { "^\\.git$" } },
            actions = {
                open_file = { quit_on_open = false, resize_window = false },
            },
        },
    },
}

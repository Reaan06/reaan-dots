-- ╭──────────────────────────────────────────────────────────────────────────╮
-- │                                                                          │
-- │   T R E E S I T T E R                                                    │
-- │   treesitter · parsers and highlighting                                  │
-- │                                                                          │
-- │   github.com/andreumassanet/impasto                                      │
-- │                                                                          │
-- ╰──────────────────────────────────────────────────────────────────────────╯

-- The generated colourscheme mostly targets treesitter captures.

return {
    {
        "nvim-treesitter/nvim-treesitter",
        branch = "main",
        build = ":TSUpdate",
        event = { "BufReadPost", "BufNewFile" },
        config = function()
            require("nvim-treesitter").setup()

            -- · the main branch does not start highlighting by itself; pcall
            --   for filetypes without a parser
            vim.api.nvim_create_autocmd("FileType", {
                group = vim.api.nvim_create_augroup("impasto_ts", { clear = true }),
                callback = function(event)
                    pcall(vim.treesitter.start, event.buf)
                end,
            })

            -- · parsers are compiled with the tree-sitter CLI
            --   (tree-sitter-cli); without it, keep neovim's bundled ones
            if vim.fn.executable("tree-sitter") == 0 then
                return
            end

            require("nvim-treesitter").install({
                "lua", "python", "bash", "qmljs", "json", "toml", "yaml",
                "markdown", "markdown_inline", "diff", "gitcommit", "vim",
                "vimdoc", "query",
            })
        end,
    },
}

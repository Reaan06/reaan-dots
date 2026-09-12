-- ╭──────────────────────────────────────────────────────────────────────────╮
-- │                                                                          │
-- │   L S P                                                                  │
-- │   language servers · started only when installed                         │
-- │                                                                          │
-- │   github.com/andreumassanet/impasto                                      │
-- │                                                                          │
-- ╰──────────────────────────────────────────────────────────────────────────╯

-- Neovim 0.11+ native LSP: nvim-lspconfig only provides the lsp/<name>.lua
-- definitions for vim.lsp.config / vim.lsp.enable.
--
-- Each server is enabled only if its binary is installed; otherwise neovim
-- reports a spawn failure on every file of that type.

-- · `cmd` only where the binary name differs: Arch ships qmlls as `qmlls6`.
local servers = {
    { name = "lua_ls",       binary = "lua-language-server" },
    { name = "ruff",         binary = "ruff" },
    { name = "bashls",       binary = "bash-language-server" },
    { name = "qmlls",        binary = "qmlls6", cmd = { "qmlls6" } },
}

-- · one Python type checker, whichever is installed (basedpyright preferred)
for _, candidate in ipairs({ "basedpyright", "pyright" }) do
    if vim.fn.executable(candidate) == 1 then
        table.insert(servers, { name = candidate, binary = candidate })
        break
    end
end

return {
    {
        "neovim/nvim-lspconfig",
        event = { "BufReadPre", "BufNewFile" },
        config = function()
            -- · `hl` is Hyprland's Lua config global
            vim.lsp.config("lua_ls", {
                settings = {
                    Lua = {
                        diagnostics = { globals = { "vim", "hl" } },
                        workspace = { checkThirdParty = false },
                        telemetry = { enable = false },
                    },
                },
            })

            for _, server in ipairs(servers) do
                if vim.fn.executable(server.binary) == 1 then
                    if server.cmd then
                        vim.lsp.config(server.name, { cmd = server.cmd })
                    end
                    vim.lsp.enable(server.name)
                end
            end

            -- · signs only, no virtual text; one glyph, with severity shown
            --   by colour
            vim.diagnostic.config({
                virtual_text = false,
                underline = true,
                severity_sort = true,
                float = { border = "rounded", source = true },
                signs = {
                    text = {
                        [vim.diagnostic.severity.ERROR] = "●",
                        [vim.diagnostic.severity.WARN]  = "●",
                        [vim.diagnostic.severity.INFO]  = "●",
                        [vim.diagnostic.severity.HINT]  = "●",
                    },
                },
            })
        end,
    },
}

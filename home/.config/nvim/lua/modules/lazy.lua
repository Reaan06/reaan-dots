-- ╭──────────────────────────────────────────────────────────────────────────╮
-- │                                                                          │
-- │   L A Z Y                                                                │
-- │   plugin manager · bootstrapped on first run                             │
-- │                                                                          │
-- │   github.com/andreumassanet/impasto                                      │
-- │                                                                          │
-- ╰──────────────────────────────────────────────────────────────────────────╯

-- lazy.nvim bootstraps itself into ~/.local/share/nvim on first run.
--
-- The lockfile goes to the state directory: ~/.config/nvim holds the copies
-- ./setup installs, and a lockfile rewritten on every update would show up
-- there as a locally edited file. It is not versioned.

local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"

if not (vim.uv or vim.loop).fs_stat(lazypath) then
    local out = vim.fn.system({
        "git", "clone", "--filter=blob:none", "--branch=stable",
        "https://github.com/folke/lazy.nvim.git", lazypath,
    })
    if vim.v.shell_error ~= 0 then
        vim.api.nvim_echo({
            { "could not clone lazy.nvim\n", "ErrorMsg" },
            { out, "WarningMsg" },
        }, true, {})
        return
    end
end

vim.opt.runtimepath:prepend(lazypath)

require("lazy").setup({
    spec = { { import = "plugins" } },

    lockfile = vim.fn.stdpath("state") .. "/lazy-lock.json",

    -- · use ours during install instead of lazy.nvim's own
    install = { colorscheme = { "impasto", "default" } },

    ui = { border = "rounded" },

    -- · no update checks on startup; use :Lazy update
    checker = { enabled = false },
    change_detection = { notify = false },

    performance = {
        rtp = {
            -- · lazy.nvim resets the runtimepath, dropping the directory
            --   theme.lua added; without this, later `:colorscheme impasto`
            --   calls (live repaints) fail with E185.
            paths = { require("modules.theme").dir },

            disabled_plugins = {
                "gzip", "tarPlugin", "tohtml", "tutor", "zipPlugin",
            },
        },
    },
})

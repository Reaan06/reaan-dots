-- ╭──────────────────────────────────────────────────────────────────────────╮
-- │                                                                          │
-- │   C O M P L E T I O N                                                    │
-- │   blink.cmp · completion from the language servers                       │
-- │                                                                          │
-- │   github.com/andreumassanet/impasto                                      │
-- │                                                                          │
-- ╰──────────────────────────────────────────────────────────────────────────╯

return {
    {
        "saghen/blink.cmp",
        event = "InsertEnter",
        -- · release tags ship the prebuilt Rust fuzzy matcher
        version = "*",
        dependencies = { "rafamadriz/friendly-snippets" },
        opts = {
            keymap = { preset = "default" },
            appearance = { nerd_font_variant = "mono" },
            completion = {
                documentation = { auto_show = true, auto_show_delay_ms = 200 },
                menu = { border = "rounded" },
            },
            sources = { default = { "lsp", "path", "snippets", "buffer" } },
            fuzzy = { implementation = "prefer_rust_with_warning" },
        },
    },
}

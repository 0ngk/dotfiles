return {
  {
    "onsails/lspkind.nvim",
    config = function()
      require("lspkind").init({
        mode = "symbol_text",
        preset = "codicons",
      })
    end,
  },
  {
    "saghen/blink.cmp",
    version = "1.*",
    event = "InsertEnter",
    dependencies = { "onsails/lspkind.nvim" },
    config = function()
      require("blink.cmp").setup({
        keymap = {
          preset = "default",
          ["<Tab>"] = { "select_and_accept", "snippet_forward", "fallback" },
          ["<S-Tab>"] = { "snippet_backward", "fallback" },
          ["<CR>"] = { "accept", "fallback" },
        },
        appearance = {
          nerd_font_variant = "mono",
        },
        completion = {
          menu = {
            border = "single",
            draw = {
              components = {
                kind_icon = {
                  text = function(ctx)
                    return require("lspkind").symbol_map[ctx.kind] or ""
                  end,
                },
              },
            },
          },
          documentation = {
            auto_show = true,
            window = { border = "single" },
          },
          ghost_text = { enabled = true },
        },
        sources = {
          default = { "lsp", "path", "snippets", "buffer" },
        },
        snippets = { preset = "default" },
        fuzzy = { implementation = "prefer_rust_with_warning" },
      })
    end,
  },
  {
    "cohama/lexima.vim",
    lazy = false,
    dependencies = { "tani/vim-artemis" },
  },
  {
    "mattn/emmet-vim",
    ft = { "html", "css", "javascriptreact", "typescriptreact", "vue", "svelte" },
  },
}

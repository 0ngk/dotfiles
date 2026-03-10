return {
  {
    "stevearc/conform.nvim",
    event = { "BufWritePre" },
    cmd = { "ConformInfo" },
    opts = {
      formatters_by_ft = {
        lua = { "stylua" },
        javascript = { "biome" },
        javascriptreact = { "biome" },
        typescript = { "biome" },
        typescriptreact = { "biome" },
        json = { "biome" },
        jsonc = { "biome" },
        css = { "biome" },
        scss = { "biome" },
        sass = { "biome" },
        python = { "ruff_format" },
        gleam = { "gleam" },
        c = { "clang-format" },
        cpp = { "clang-format" },
        sh = { "shfmt" },
        bash = { "shfmt" },
        zsh = { "shfmt" },
        nix = { "alejandra" },
        kotlin = { "ktlint" },
        rust = { "rustfmt" },
        go = { "gofmt", "goimports" },
        cs = { "csharpier" },
        elixir = { "mix" },
        ["*"] = { "trim_whitespace" },
      },
      default_format_opts = {
        lsp_format = "fallback",
      },
      format_on_save = {
        timeout_ms = 500,
      },
      formatters = {
        stylua = {
          append_args = { "--indent-type", "Spaces", "--indent-width", "2" },
        },
        shfmt = {
          append_args = { "-i", "2", "-ci", "-s" },
        },
        gleam = {
          command = "gleam",
          args = { "format", "--stdin" },
          stdin = true,
        },
        cs = {
          command = "csharpier",
          args = { "--stdin" },
          stdin = true,
        },
        mix = {
          command = "mix",
          args = { "format", "--stdin-filename", "$FILENAME", "-" },
          stdin = true,
        },
      },
    },
  },
}

vim.filetype.add({
  extension = {
    fsproj = "xml",
    csproj = "xml",
    vbproj = "xml",
    props = "xml",
    targets = "xml",
    slnx = "xml",
  },
})

return {
  {
    "stevearc/conform.nvim",
    event = { "BufWritePre" },
    cmd = { "ConformInfo" },
    opts = {
      formatters_by_ft = {
        xml = { "xml" },
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
        fsharp = { "fantomas" },
        elixir = { "mix" },
        ["*"] = { "trim_whitespace" },
      },
      default_format_opts = {
        lsp_format = "fallback",
      },
      format_on_save = function(bufnr)
        local filetype = vim.bo[bufnr].filetype
        local timeout_ms = (filetype == "fsharp" or filetype == "kotlin") and 5000 or 1000
        return {
          lsp_format = "fallback",
          timeout_ms = timeout_ms,
        }
      end,
      formatters = {
        xml = {
          {
            exe = "xmllint",
            args = { "--format", "-" },
            stdin = true,
          },
        },
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

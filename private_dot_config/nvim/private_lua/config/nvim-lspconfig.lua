local on_attach = function(client, bufnr)
  vim.keymap.set("n", "gd", vim.lsp.buf.definition, { buffer = bufnr, desc = "Go to Definition" })
  vim.keymap.set("n", "K", vim.lsp.buf.hover, { buffer = bufnr, desc = "Hover Documentation" })
  vim.keymap.set("n", "gi", vim.lsp.buf.implementation, { buffer = bufnr, desc = "Go to Implementation" })
  vim.keymap.set("n", "<leader>rn", vim.lsp.buf.rename, { buffer = bufnr, desc = "Rename" })
  vim.keymap.set({ "n", "v" }, "<leader>ca", vim.lsp.buf.code_action, { buffer = bufnr, desc = "Code Action" })

  -- inlay hint
  if client.supports_method("textDocument/inlayHint") then
    vim.lsp.inlay_hint.enable(true, { bufnr = bufnr })
  end

  -- nvim-navic breadcrumbs
  if client.server_capabilities.documentSymbolProvider then
    require("nvim-navic").attach(client, bufnr)
  end
end

local capabilities = require("blink.cmp").get_lsp_capabilities()

capabilities = vim.tbl_deep_extend("force", capabilities, {
  textDocument = {
    definition = {
      dynamicRegistration = false,
      linkSupport = true,
    },
    foldingRange = {
      dynamicRegistration = false,
      lineFoldingOnly = true,
    },
  },
  offsetEncoding = { "utf-8", "utf-16" },
})

local lua_library_paths = {
  vim.env.VIMRUNTIME .. "/lua",
  vim.env.VIMRUNTIME .. "/lua/vim/_meta",
  vim.fn.stdpath("config") .. "/lua",
}

local lua_unique_library_paths = {}
local lua_seen_paths = {}
for _, path in ipairs(lua_library_paths) do
  if path and not lua_seen_paths[path] then
    table.insert(lua_unique_library_paths, path)
    lua_seen_paths[path] = true
  end
end

-- Biome
vim.lsp.config("biome", {
  on_attach = on_attach,
  capabilities = capabilities,
})

-- Deno
vim.lsp.config("denols", {
  on_attach = on_attach,
  capabilities = capabilities,
  root_markers = { "deno.json", "deno.jsonc" },
  workspace_required = true,
})

-- Go
vim.lsp.config("gopls", {
  on_attach = on_attach,
  capabilities = capabilities,
})

-- Perl
vim.lsp.config("perlnavigator", {
  on_attach = on_attach,
  capabilities = capabilities,
})

-- Python
vim.lsp.config("pyright", {
  on_attach = on_attach,
  capabilities = capabilities,
  settings = {
    python = {
      analysis = {
        autoSearchPaths = true,
        useLibraryCodeForTypes = true,
        diagnosticMode = "workspace",
      },
    },
  },
})

-- PHP
vim.lsp.config("phpactor", {
  on_attach = on_attach,
  capabilities = capabilities,
  filetypes = { "php", "php3", "php4", "php5", "phtml" },
  cmd = { "phpactor", "language-server" },
  init_options = {
    ["language_server_configuration.auto_config"] = false,
  },
  root_dir = function(bufnr, on_dir)
    local root = vim.fs.root(bufnr, { ".git", "composer.json", ".phpactor.json", ".phpactor.yml" })
    if root then
      on_dir(root)
    else
      -- フォールバック: ファイルの親ディレクトリを使用
      local fname = vim.api.nvim_buf_get_name(bufnr)
      on_dir(vim.fn.fnamemodify(fname, ":h"))
    end
  end,
  workspace_required = false,
})

-- Rust
vim.lsp.config("rust_analyzer", {
  on_attach = on_attach,
  capabilities = capabilities,
})

-- HTML
vim.lsp.config("html", {
  on_attach = on_attach,
  capabilities = capabilities,
  cmd = { "superhtml", "lsp" },
})

-- TypeScript / JavaScript
vim.lsp.config("ts_ls", {
  on_attach = on_attach,
  capabilities = capabilities,
  root_dir = function(bufnr, on_dir)
    local fname = vim.api.nvim_buf_get_name(bufnr)
    -- denols との競合を避けるため、deno.json があるプロジェクトでは起動しない
    local deno_root = vim.fs.root(bufnr, { "deno.json", "deno.jsonc" })
    if deno_root then
      return nil
    end
    local root = vim.fs.root(bufnr, { "tsconfig.json", "jsconfig.json", "package.json", ".git" })
    if root then
      on_dir(root)
    end
  end,
  workspace_required = true,
})

-- Gleam
vim.lsp.config("gleam", {
  on_attach = on_attach,
  capabilities = capabilities,
})

-- C/C++
vim.lsp.config("clangd", {
  on_attach = on_attach,
  capabilities = capabilities,
  cmd = {
    "clangd",
    "--background-index",
    "--clang-tidy",
    "--completion-style=detailed",
    "--header-insertion=iwyu",
  },
})

-- Lua
vim.lsp.config("lua", {
  on_attach = on_attach,
  capabilities = capabilities,
  filetypes = { "lua" },
  cmd = {
    "emmylua_ls",
  },
  settings = {
    Lua = {
      runtime = {
        version = "LuaJIT",
        pathStrict = true,
      },
      workspace = {
        library = lua_unique_library_paths,
        checkThirdParty = false,
        ignoreDir = {
          ".*",
        },
      },
      telemetry = { enable = false },
      hint = {
        enable = true,
        arrayIndex = "Enable",
        setType = true,
      },
    },
  },
  workspace_required = false,
})

-- Bash
vim.lsp.config("bashls", {
  on_attach = on_attach,
  capabilities = capabilities,
  filetypes = { "sh", "bash", "zsh" },
  cmd = { "bash-language-server", "start" },
})

-- Kotlin
vim.lsp.config("kotlin-lsp", {
  on_attach = on_attach,
  capabilities = capabilities,
  filetypes = { "kotlin" },
  cmd = { "kotlin-lsp", "--stdio" },
})

-- YAML
vim.lsp.config("yaml-language-server", {
  on_attach = on_attach,
  capabilities = capabilities,
  filetypes = { "yaml" },
  cmd = { "yaml-language-server", "--stdio" },
})

-- C#
vim.lsp.config("csharp-ls", {
  on_attach = on_attach,
  capabilities = capabilities,
  filetypes = { "cs" },
  cmd = { "csharp-ls" },
})

-- Erlang
-- vim.lsp.config("erlls", {
--   on_attach = on_attach,
--   capabilities = capabilities,
--   cmd = { "erlls" },
-- })

-- Elixir
vim.lsp.config("expert", {
  cmd = { "expert", "--stdio" },
  root_markers = { "mix.exs", ".git" },
  filetypes = { "elixir", "eelixir", "heex" },
})

-- Enable all configured LSP servers
vim.lsp.enable({
  "biome",
  "denols",
  "gopls",
  "perlnavigator",
  "pyright",
  "phpactor",
  "rust_analyzer",
  "html",
  "ts_ls",
  "gleam",
  "clangd",
  "lua",
  "bashls",
  "kotlin-lsp",
  "yaml-language-server",
  "csharp-ls",
  "erlls",
  "expert",
})

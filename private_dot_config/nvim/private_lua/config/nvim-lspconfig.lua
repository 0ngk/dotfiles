local fsharp_definition = require("config.fsharp_definition")

fsharp_definition.setup()

local on_attach = function(client, bufnr)
  vim.keymap.set("n", "gd", function()
    fsharp_definition.go_to_definition_with_fallback()
  end, { buffer = bufnr, desc = "Go to Definition" })
  vim.keymap.set("n", ">", function()
    vim.lsp.buf.hover()
  end, { buffer = bufnr, desc = "Hover Documentation" })
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

-- xmllint
vim.lsp.config("xmllint", {
  filetypes = { "xml" },
  cmd = { "xmllint" },
})

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

vim.api.nvim_create_autocmd("BufReadCmd", {
  pattern = "deno:/*",
  callback = function(event)
    local buf = event.buf
    local uri = event.match

    local clients = vim.lsp.get_clients({ name = "denols" })
    if #clients == 0 then
      return
    end

    local result = clients[1]:request_sync("deno/virtualTextDocument", {
      textDocument = { uri = uri },
    }, 5000)

    if result and result.result then
      local lines = vim.split(result.result, "\n", { plain = true })
      vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
    end

    vim.bo[buf].modifiable = false
    vim.bo[buf].modified = false
    vim.bo[buf].readonly = true
    vim.bo[buf].filetype = "typescript"
  end,
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

-- CSS
vim.lsp.config("cssls", {
  on_attach = on_attach,
  capabilities = capabilities,
})

-- TypeScript / JavaScript
vim.lsp.config("ts_ls", {
  on_attach = on_attach,
  capabilities = capabilities,
  settings = {
    typescript = {
      inlayHints = {
        includeInlayParameterNameHints = "all",
        includeInlayParameterNameHintsWhenArgumentMatchesName = false,
        includeInlayFunctionParameterTypeHints = true,
        includeInlayVariableTypeHints = true,
        includeInlayPropertyDeclarationTypeHints = true,
        includeInlayFunctionLikeReturnTypeHints = true,
        includeInlayEnumMemberValueHints = true,
      },
    },
    javascript = {
      inlayHints = {
        includeInlayParameterNameHints = "all",
        includeInlayParameterNameHintsWhenArgumentMatchesName = false,
        includeInlayFunctionParameterTypeHints = true,
        includeInlayVariableTypeHints = true,
        includeInlayPropertyDeclarationTypeHints = true,
        includeInlayFunctionLikeReturnTypeHints = true,
        includeInlayEnumMemberValueHints = true,
      },
    },
  },
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
local gleam_dev = vim.fn.expand("~/.local/opt/gleam-main/bin/gleam")
local gleam_cmd = vim.fn.executable(gleam_dev) == 1 and { gleam_dev, "lsp" } or { "gleam", "lsp" }

vim.lsp.config("gleam", {
  on_attach = on_attach,
  capabilities = capabilities,
  cmd = gleam_cmd,
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

-- YAML
vim.lsp.config("yaml-language-server", {
  on_attach = on_attach,
  capabilities = capabilities,
  filetypes = { "yaml" },
  cmd = { "yaml-language-server", "--stdio" },
})

-- C# / Roslyn
vim.lsp.config("roslyn", {
  on_attach = on_attach,
  capabilities = capabilities,
  settings = {
    ["csharp|background_analysis"] = {
      dotnet_analyzer_diagnostics_scope = "fullSolution",
      dotnet_compiler_diagnostics_scope = "fullSolution",
    },
    ["csharp|inlay_hints"] = {
      csharp_enable_inlay_hints_for_implicit_object_creation = true,
      csharp_enable_inlay_hints_for_implicit_variable_types = true,
      csharp_enable_inlay_hints_for_lambda_parameter_types = true,
      csharp_enable_inlay_hints_for_types = true,
      dotnet_enable_inlay_hints_for_indexer_parameters = true,
      dotnet_enable_inlay_hints_for_literal_parameters = true,
      dotnet_enable_inlay_hints_for_object_creation_parameters = true,
      dotnet_enable_inlay_hints_for_other_parameters = true,
      dotnet_enable_inlay_hints_for_parameters = true,
      dotnet_suppress_inlay_hints_for_parameters_that_differ_only_by_suffix = true,
      dotnet_suppress_inlay_hints_for_parameters_that_match_argument_name = true,
      dotnet_suppress_inlay_hints_for_parameters_that_match_method_intent = true,
    },
    ["csharp|symbol_search"] = {
      dotnet_search_reference_assemblies = true,
    },
    ["csharp|completion"] = {
      dotnet_show_name_completion_suggestions = true,
      dotnet_show_completion_items_from_unimported_namespaces = true,
      dotnet_provide_regex_completions = true,
    },
    ["csharp|code_lens"] = {
      dotnet_enable_references_code_lens = true,
    },
  },
})

local function is_dotnet_root(path)
  if type(path) ~= "string" or path == "" then
    return false
  end

  return vim.fn.isdirectory(path .. "/sdk") == 1 and vim.fn.executable(path .. "/dotnet") == 1
end

local function resolve_dotnet_root()
  local dotnet_root = vim.env.DOTNET_ROOT
  if is_dotnet_root(dotnet_root) then
    return dotnet_root
  end

  local dotnet = vim.fn.exepath("dotnet")
  if dotnet == "" then
    return nil
  end

  local resolved_dotnet = vim.fn.resolve(dotnet)
  local dotnet_dir = vim.fs.dirname(resolved_dotnet)
  if type(dotnet_dir) ~= "string" or dotnet_dir == "" then
    return nil
  end

  local candidates = {}
  local function add_candidate(path)
    if type(path) == "string" and path ~= "" then
      table.insert(candidates, path)
    end
  end

  add_candidate(dotnet_dir)
  if vim.fs.basename(dotnet_dir) == "bin" then
    local dotnet_prefix = vim.fs.dirname(dotnet_dir)
    add_candidate(dotnet_prefix)
    if type(dotnet_prefix) == "string" and dotnet_prefix ~= "" then
      add_candidate(dotnet_prefix .. "/libexec")
    end
  end

  for _, candidate in ipairs(candidates) do
    if is_dotnet_root(candidate) then
      return candidate
    end
  end

  return nil
end

local fsautocomplete_cmd_env = nil
local fsautocomplete_dotnet_root = resolve_dotnet_root()
if fsautocomplete_dotnet_root then
  fsautocomplete_cmd_env = {
    DOTNET_ROOT = fsautocomplete_dotnet_root,
  }
end

-- F#
vim.lsp.config("fsautocomplete", {
  on_attach = on_attach,
  capabilities = capabilities,
  filetypes = { "fsharp" },
  cmd = { "fsautocomplete", "--adaptive-lsp-server-enabled" },
  cmd_env = fsautocomplete_cmd_env,
  root_markers = { "*.sln", "*.slnx", "*.fsproj", ".git" },
  init_options = {
    AutomaticWorkspaceInit = true,
  },
  settings = {
    FSharp = {
      keywordsAutocomplete = true,
      ExternalAutocomplete = false,
      Linter = true,
      UseSdkScripts = true,
      ResolveNamespaces = true,
      EnableReferenceCodeLens = true,
      UnusedOpensAnalyzer = true,
      UnusedDeclarationsAnalyzer = true,
      SimplifyNameAnalyzer = true,
    },
  },
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
  "cssls",
  "ts_ls",
  "gleam",
  "clangd",
  "lua",
  "bashls",
  "yaml-language-server",
  "fsautocomplete",
  "erlls",
  "expert",
})

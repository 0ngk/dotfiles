local lua_config = require("config.lsp.lua")

local M = {}

M.enabled = {
  "biome",
  "denols",
  "gopls",
  "perlnavigator",
  "pyright",
  "phpactor",
  "rust_analyzer",
  "superhtml",
  "cssls",
  "ts_ls",
  "gleam",
  "clangd",
  "emmylua_ls",
  "bashls",
  "yamlls",
  "fsautocomplete",
  "expert",
  "sqls",
}

local function merge_common(common, config)
  return vim.tbl_deep_extend("force", common, config or {})
end

function M.setup(opts)
  local common = {
    on_attach = opts.on_attach,
    capabilities = opts.capabilities,
  }

  -- Biome
  vim.lsp.config("biome", common)

  -- Deno
  vim.lsp.config(
    "denols",
    merge_common(common, {
      root_markers = { "deno.json", "deno.jsonc" },
      workspace_required = true,
    })
  )

  -- Go
  vim.lsp.config("gopls", common)

  -- Perl
  vim.lsp.config("perlnavigator", common)

  -- Python
  vim.lsp.config(
    "pyright",
    merge_common(common, {
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
  )

  -- PHP
  vim.lsp.config(
    "phpactor",
    merge_common(common, {
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
          local fname = vim.api.nvim_buf_get_name(bufnr)
          on_dir(vim.fn.fnamemodify(fname, ":h"))
        end
      end,
      workspace_required = false,
    })
  )

  -- Rust
  vim.lsp.config("rust_analyzer", common)

  -- HTML
  vim.lsp.config("superhtml", common)

  -- CSS
  vim.lsp.config("cssls", common)

  -- TypeScript / JavaScript
  vim.lsp.config(
    "ts_ls",
    merge_common(common, {
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
  )

  -- Gleam
  local gleam_dev = vim.fn.expand("~/.local/opt/gleam-main/bin/gleam")
  local gleam_cmd = vim.fn.executable(gleam_dev) == 1 and { gleam_dev, "lsp" } or { "gleam", "lsp" }
  vim.lsp.config(
    "gleam",
    merge_common(common, {
      cmd = gleam_cmd,
    })
  )

  -- C/C++
  vim.lsp.config(
    "clangd",
    merge_common(common, {
      cmd = {
        "clangd",
        "--background-index",
        "--clang-tidy",
        "--completion-style=detailed",
        "--header-insertion=iwyu",
      },
    })
  )

  -- Lua
  vim.lsp.config(
    "emmylua_ls",
    merge_common(common, {
      settings = {
        emmylua = {
          runtime = {
            version = "LuaJIT",
            pathStrict = true,
          },
          diagnostics = {
            globals = { "vim" },
          },
          workspace = {
            library = lua_config.library_paths(),
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
  )

  -- Bash
  vim.lsp.config(
    "bashls",
    merge_common(common, {
      filetypes = { "sh", "bash", "zsh" },
      cmd = { "bash-language-server", "start" },
    })
  )

  -- YAML
  vim.lsp.config("yamlls", common)

  -- C# / Roslyn. roslyn.nvim starts this server, so it is configured but not enabled here.
  vim.lsp.config(
    "roslyn",
    merge_common(common, {
      on_attach = opts.roslyn_on_attach,
      settings = {
        ["csharp|background_analysis"] = {
          dotnet_analyzer_diagnostics_scope = "openFiles",
          dotnet_compiler_diagnostics_scope = "openFiles",
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
  )

  -- F#
  vim.lsp.config(
    "fsautocomplete",
    merge_common(common, {
      filetypes = { "fsharp" },
      cmd = { "fsautocomplete" },
      flags = { debounce_text_changes = 300 },
      cmd_env = opts.fsautocomplete_cmd_env,
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
  )

  -- Elixir
  vim.lsp.config(
    "expert",
    merge_common(common, {
      cmd = { "expert", "--stdio" },
      root_markers = { "mix.exs", ".git" },
      filetypes = { "elixir", "eelixir", "heex" },
    })
  )

  -- SQL
  vim.lsp.config(
    "sqls",
    merge_common(common, {
      cmd = { "sqls" },
      filetypes = { "sql" },
    })
  )
end

return M

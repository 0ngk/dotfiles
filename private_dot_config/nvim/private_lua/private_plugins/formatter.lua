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

local deno_root_markers = { "deno.json", "deno.jsonc" }
local gradle_root_markers = { "gradlew" }

local function is_deno_project(bufnr)
  return vim.fs.root(bufnr, deno_root_markers) ~= nil
end

local function js_ts_json_formatter(bufnr)
  if is_deno_project(bufnr) then
    return { "deno_fmt" }
  end

  return { "biome" }
end

local function is_gradle_kotlin_dsl(bufnr)
  local filename = vim.api.nvim_buf_get_name(bufnr)
  local basename = vim.fs.basename(filename)
  return basename == "settings.gradle.kts" or filename:match("%.gradle%.kts$") ~= nil
end

local function read_project_file(root, filename)
  local path = vim.fs.joinpath(root, filename)
  if vim.fn.filereadable(path) == 0 then
    return nil
  end

  return table.concat(vim.fn.readfile(path), "\n")
end

local function gradle_root(bufnr)
  return vim.fs.root(bufnr, gradle_root_markers)
end

local function is_spotless_gradle_project(bufnr)
  local root = gradle_root(bufnr)
  if root == nil then
    return false
  end

  local build_file = read_project_file(root, "build.gradle.kts") or read_project_file(root, "build.gradle")
  if build_file == nil then
    return false
  end

  return build_file:find("com.diffplug.spotless", 1, true) ~= nil
end

local function spotless_gradle_formatter(bufnr)
  if is_spotless_gradle_project(bufnr) then
    return { "spotless_gradle" }
  end

  return {}
end

local function java_formatter(bufnr)
  if is_spotless_gradle_project(bufnr) then
    return spotless_gradle_formatter(bufnr)
  end

  return { "palantir-java-format" }
end

local function kotlin_formatter(bufnr)
  if is_gradle_kotlin_dsl(bufnr) and is_spotless_gradle_project(bufnr) then
    return spotless_gradle_formatter(bufnr)
  end

  return { "ktlint" }
end

local function is_spotless_gradle_target(bufnr)
  local filetype = vim.bo[bufnr].filetype
  return is_spotless_gradle_project(bufnr)
    and (filetype == "java" or (filetype == "kotlin" and is_gradle_kotlin_dsl(bufnr)))
end

return {
  {
    "stevearc/conform.nvim",
    event = { "BufWritePre" },
    cmd = { "ConformInfo" },
    opts = {
      formatters_by_ft = {
        xml = { "xml" },
        lua = { "stylua" },
        javascript = js_ts_json_formatter,
        javascriptreact = js_ts_json_formatter,
        typescript = js_ts_json_formatter,
        typescriptreact = js_ts_json_formatter,
        json = js_ts_json_formatter,
        jsonc = js_ts_json_formatter,
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
        java = java_formatter,
        kotlin = kotlin_formatter,
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
        local is_spotless_target = is_spotless_gradle_target(bufnr)
        local timeout_ms = 1000
        if is_spotless_target then
          timeout_ms = 30000
        elseif filetype == "fsharp" or filetype == "java" or filetype == "kotlin" then
          timeout_ms = 5000
        end

        return {
          lsp_format = is_spotless_target and "never" or "fallback",
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

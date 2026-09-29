local project = require("config.fsharp.project")

local M = {}

local function notify(message, level)
  vim.notify(message, level or vim.log.levels.INFO, { title = "F# Runtime" })
end

local function first_line(message)
  if type(message) ~= "string" then
    return ""
  end
  return message:match("([^\n]+)") or message
end

local function build_project_debug(fsproj)
  local output = vim.fn.system({ "dotnet", "build", "-c", "Debug", fsproj })
  if vim.v.shell_error ~= 0 then
    notify(("dotnet build failed: %s"):format(first_line(output)), vim.log.levels.ERROR)
    return false
  end
  return true
end

local function resolve_netcoredbg()
  local path = vim.fn.exepath("netcoredbg")
  if path ~= "" then
    return path
  end

  local mason_path = vim.fn.stdpath("data") .. "/mason/bin/netcoredbg"
  if vim.fn.executable(mason_path) == 1 then
    return mason_path
  end

  return nil
end

local function make_debug_program(state)
  return function()
    local dap = require("dap")
    local fsproj = project.select_project_sync("debug")

    if not fsproj then
      return dap.ABORT
    end

    if not build_project_debug(fsproj) then
      return dap.ABORT
    end

    local dll = project.resolve_dll_path(fsproj)
    if not dll then
      notify("Debug launch cancelled: DLL path is empty.", vim.log.levels.WARN)
      return dap.ABORT
    end

    state.last_run = { fsproj = fsproj }
    return dll
  end
end

function M.setup(state)
  local dap = require("dap")
  local netcoredbg = resolve_netcoredbg()

  if netcoredbg then
    dap.adapters.coreclr = {
      type = "executable",
      command = netcoredbg,
      args = { "--interpreter=vscode" },
    }
  else
    notify("netcoredbg not found. Install adapter `coreclr` via Mason.", vim.log.levels.WARN)
  end

  local config = {
    type = "coreclr",
    name = "Launch F# (netcoredbg)",
    request = "launch",
    program = make_debug_program(state),
    cwd = "${workspaceFolder}",
    stopAtEntry = false,
  }

  local configs = dap.configurations.fsharp or {}
  local replaced = false

  for index, existing in ipairs(configs) do
    if existing.name == config.name then
      configs[index] = config
      replaced = true
      break
    end
  end

  if not replaced then
    table.insert(configs, config)
  end

  dap.configurations.fsharp = configs
end

return M

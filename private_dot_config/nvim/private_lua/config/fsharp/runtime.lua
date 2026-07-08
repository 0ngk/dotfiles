local dap_config = require("config.fsharp.dap")
local project = require("config.fsharp.project")

local M = {}

local RUN_TERMINAL_COUNT = 96

local state = {
  commands_setup = false,
  last_terminal = nil,
  last_run = nil,
}

local function notify(message, level)
  vim.notify(message, level or vim.log.levels.INFO, { title = "F# Runtime" })
end

local function close_last_terminal()
  local terminal = state.last_terminal
  if not terminal then
    return
  end

  local ok, valid = pcall(function()
    return terminal:buf_valid()
  end)

  if ok and valid then
    pcall(function()
      terminal:close()
    end)
  end

  state.last_terminal = nil
end

local function run_project(fsproj)
  local ok, snacks = pcall(require, "snacks")
  if not ok then
    notify("snacks.nvim is not available.", vim.log.levels.ERROR)
    return
  end

  close_last_terminal()

  local cmd = { "dotnet", "run", "--project", fsproj }
  local opts = {
    count = RUN_TERMINAL_COUNT,
    cwd = project.dirname(fsproj),
    interactive = false,
    start_insert = true,
    auto_insert = true,
    auto_close = false,
    win = {
      position = "float",
      border = "rounded",
      width = 0.92,
      height = 0.86,
      backdrop = 60,
      title = " F# Run ",
      title_pos = "center",
    },
  }

  state.last_terminal = snacks.terminal.toggle(cmd, opts)
  state.last_run = { fsproj = fsproj }

  notify(("Running: %s"):format(vim.fn.fnamemodify(fsproj, ":.")))
end

function M.run()
  local fsproj = project.select_project_sync("run")
  if not fsproj then
    return
  end
  run_project(fsproj)
end

function M.run_last()
  if not state.last_run or not state.last_run.fsproj then
    notify("No previous F# run target. Use :FSharpRun first.", vim.log.levels.WARN)
    return
  end
  run_project(state.last_run.fsproj)
end

function M.setup()
  if state.commands_setup then
    return
  end
  state.commands_setup = true

  vim.api.nvim_create_user_command("FSharpRun", function()
    M.run()
  end, { desc = "Run F# project with dotnet run" })

  vim.api.nvim_create_user_command("FSharpRunLast", function()
    M.run_last()
  end, { desc = "Run the last F# project again" })
end

function M.setup_dap()
  dap_config.setup(state)
end

return M

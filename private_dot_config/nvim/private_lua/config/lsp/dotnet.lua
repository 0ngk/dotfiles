local M = {}

local roslyn_unity_warned_roots = {}

local function find_unity_project_root(bufnr)
  local buffer_path = vim.api.nvim_buf_get_name(bufnr)
  if type(buffer_path) ~= "string" or buffer_path == "" then
    return nil
  end

  local project_version = vim.fs.find("ProjectSettings/ProjectVersion.txt", {
    upward = true,
    path = buffer_path,
    limit = 1,
  })[1]
  if not project_version then
    return nil
  end

  local project_settings_dir = vim.fs.dirname(project_version)
  if not project_settings_dir then
    return nil
  end

  return vim.fs.dirname(project_settings_dir)
end

local function scan_unity_csharp_targets(project_root)
  local status = {
    has_solution = false,
    has_csproj = false,
  }

  if type(project_root) ~= "string" or project_root == "" then
    return status
  end

  for entry, kind in vim.fs.dir(project_root) do
    if kind == "file" then
      if entry:match("%.sln$") or entry:match("%.slnx$") or entry:match("%.slnf$") then
        status.has_solution = true
      elseif entry:match("%.csproj$") then
        status.has_csproj = true
      end

      if status.has_solution and status.has_csproj then
        break
      end
    end
  end

  return status
end

function M.notify_unity_roslyn_project_state(client, bufnr)
  if client.name ~= "roslyn" then
    return
  end

  local project_root = find_unity_project_root(bufnr)
  if not project_root then
    return
  end

  local status = scan_unity_csharp_targets(project_root)
  local root_dir = client.config and client.config.root_dir or nil

  if root_dir and status.has_solution and status.has_csproj then
    return
  end

  if roslyn_unity_warned_roots[project_root] then
    return
  end
  roslyn_unity_warned_roots[project_root] = true

  vim.notify(
    (
      "Roslyn has no Unity solution/project context for:\n%s\n\n"
      .. "In Unity: Edit > Preferences > External Tools,\n"
      .. "enable Generate .csproj files options, then run Regenerate project files."
    ):format(project_root),
    vim.log.levels.WARN,
    { title = "roslyn.nvim" }
  )
end

local function roslyn_unity_status()
  local bufnr = vim.api.nvim_get_current_buf()
  local project_root = find_unity_project_root(bufnr)
  if not project_root then
    print("RoslynUnityStatus: current buffer is not inside a Unity project.")
    return
  end

  local status = scan_unity_csharp_targets(project_root)
  local client = vim.lsp.get_clients({ bufnr = bufnr, name = "roslyn" })[1]
  local root_dir = client and client.config and client.config.root_dir or nil

  print(table.concat({
    "RoslynUnityStatus",
    "  unity_root: " .. project_root,
    "  roslyn_root_dir: " .. (root_dir or "nil"),
    "  has_solution: " .. tostring(status.has_solution),
    "  has_csproj: " .. tostring(status.has_csproj),
  }, "\n"))
end

function M.setup()
  vim.api.nvim_create_user_command("RoslynUnityStatus", roslyn_unity_status, {
    desc = "Show Unity + Roslyn project-file status",
  })
end

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

function M.fsautocomplete_cmd_env()
  local dotnet_root = resolve_dotnet_root()
  if not dotnet_root then
    return nil
  end

  return {
    DOTNET_ROOT = dotnet_root,
  }
end

return M

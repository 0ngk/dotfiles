local M = {}

local function notify(message, level)
  vim.notify(message, level or vim.log.levels.INFO, { title = "F# Runtime" })
end

local function trim(value)
  if type(value) ~= "string" then
    return nil
  end
  return (value:gsub("^%s+", ""):gsub("%s+$", ""))
end

function M.dirname(path)
  return vim.fn.fnamemodify(path, ":h")
end

local function project_display_path(path, root)
  local prefix = root .. "/"
  if path:sub(1, #prefix) == prefix then
    return path:sub(#prefix + 1)
  end
  return path
end

local function get_search_root()
  local buf = vim.api.nvim_get_current_buf()
  local name = vim.api.nvim_buf_get_name(buf)
  local start = name ~= "" and M.dirname(name) or vim.fn.getcwd()
  return vim.fs.root(start, { ".git" }) or start
end

function M.find_fsharp_projects()
  local root = get_search_root()
  local files = vim.fn.globpath(root, "**/*.fsproj", false, true)
  local projects = {}
  local seen = {}

  for _, file in ipairs(files) do
    local normalized = vim.fn.fnamemodify(file, ":p")
    if not normalized:find("/bin/", 1, true) and not normalized:find("/obj/", 1, true) then
      if vim.fn.filereadable(normalized) == 1 and not seen[normalized] then
        seen[normalized] = true
        table.insert(projects, normalized)
      end
    end
  end

  table.sort(projects)
  return projects, root
end

function M.select_project_sync(purpose)
  local projects, root = M.find_fsharp_projects()

  if #projects == 0 then
    notify(("No .fsproj found under %s"):format(root), vim.log.levels.WARN)
    return nil
  end

  if #projects == 1 then
    return projects[1]
  end

  local menu = { ("Select F# project for %s:"):format(purpose) }
  for index, fsproj in ipairs(projects) do
    table.insert(menu, ("%d. %s"):format(index, project_display_path(fsproj, root)))
  end

  local choice = vim.fn.inputlist(menu)
  if choice < 1 or choice > #projects then
    notify("Project selection cancelled.", vim.log.levels.INFO)
    return nil
  end

  return projects[choice]
end

local function read_file(path)
  local fd = io.open(path, "r")
  if not fd then
    return nil
  end
  local content = fd:read("*a")
  fd:close()
  return content
end

function M.parse_project_metadata(fsproj)
  local assembly_name = vim.fn.fnamemodify(fsproj, ":t:r")
  local target_framework = nil
  local content = read_file(fsproj)

  if content then
    assembly_name = trim(content:match("<AssemblyName>%s*(.-)%s*</AssemblyName>")) or assembly_name

    local tfm = trim(content:match("<TargetFramework>%s*(.-)%s*</TargetFramework>"))
    if tfm and tfm ~= "" then
      target_framework = tfm
    else
      local tfms = trim(content:match("<TargetFrameworks>%s*(.-)%s*</TargetFrameworks>"))
      if tfms and tfms ~= "" then
        target_framework = trim((tfms:match("([^;]+)")))
      end
    end
  end

  return {
    assembly_name = assembly_name,
    target_framework = target_framework,
  }
end

function M.resolve_dll_path(fsproj)
  local project_dir = M.dirname(fsproj)
  local debug_dir = project_dir .. "/bin/Debug"
  local metadata = M.parse_project_metadata(fsproj)
  local dll_name = metadata.assembly_name .. ".dll"
  local candidates = {}

  if metadata.target_framework and metadata.target_framework ~= "" then
    table.insert(candidates, ("%s/%s/%s"):format(debug_dir, metadata.target_framework, dll_name))
  end
  table.insert(candidates, ("%s/%s"):format(debug_dir, dll_name))

  for _, candidate in ipairs(candidates) do
    if vim.fn.filereadable(candidate) == 1 then
      return candidate
    end
  end

  local recursive_matches = vim.fn.globpath(debug_dir, "**/" .. dll_name, false, true)
  if type(recursive_matches) == "table" and #recursive_matches > 0 then
    table.sort(recursive_matches)
    return recursive_matches[1]
  end

  local manual = vim.fn.input("Path to dll: ", debug_dir .. "/", "file")
  if manual == "" then
    return nil
  end
  return manual
end

return M

local M = {}

function M.library_paths()
  local paths = {
    vim.env.VIMRUNTIME .. "/lua",
    vim.env.VIMRUNTIME .. "/lua/vim/_meta",
    vim.fn.stdpath("config") .. "/lua",
  }

  local unique_paths = {}
  local seen_paths = {}
  for _, path in ipairs(paths) do
    if path and not seen_paths[path] then
      table.insert(unique_paths, path)
      seen_paths[path] = true
    end
  end

  return unique_paths
end

return M

local M = {}

function M.setup()
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
end

return M

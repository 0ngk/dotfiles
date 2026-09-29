local dir = vim.fn.stdpath("config") .. "/snippets/"
local files = vim.fn.glob(dir .. "*.*", true, true)

for _, file in ipairs(files) do
  vim.fn["denippet#load"](file)
end

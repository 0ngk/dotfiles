local telescope = require("telescope")
local telescopeConfig = require("telescope.config")

local vimgrep_arguments = { unpack(telescopeConfig.values.vimgrep_arguments) }

table.insert(vimgrep_arguments, "--hidden")

table.insert(vimgrep_arguments, "--glob")

table.insert(vimgrep_arguments, "!**/.git/*")
table.insert(vimgrep_arguments, "--glob")
table.insert(vimgrep_arguments, "!**/.env")
table.insert(vimgrep_arguments, "--glob")
table.insert(vimgrep_arguments, "!**/.env.*")

telescope.setup({
  defaults = {
    winblend = 0,
    vimgrep_arguments = vimgrep_arguments,
  },
  pickers = {
    find_files = {
      hidden = true,
    },
  },
})

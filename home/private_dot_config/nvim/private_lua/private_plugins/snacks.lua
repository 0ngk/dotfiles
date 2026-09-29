return {
  {
    "folke/snacks.nvim",
    lazy = false,
    priority = 1000,
    ---@type snacks.Config
    opts = {
      picker = {
        enabled = true,
        sources = {
          files = { hidden = true },
          grep = { hidden = true },
        },
      },
      notifier = { enabled = true },
      indent = {
        enabled = true,
      },
      explorer = { enabled = false },
      terminal = { enabled = true },
      lazygit = { enabled = true },
      scroll = { enabled = true },
      zen = { enabled = true },
      words = { enabled = true },
      gitbrowse = { enabled = true },
      rename = { enabled = true },
      dim = { enabled = true },
      statuscolumn = { enabled = true },
      bigfile = { enabled = true },
      quickfile = { enabled = true },
    },
    keys = {
      -- Picker (telescope replacement)
      {
        "<leader>f",
        function()
          require("snacks").picker.files()
        end,
        desc = "Find Files",
      },
      {
        "<leader>g",
        function()
          require("snacks").picker.grep()
        end,
        desc = "Grep",
      },
      {
        "<leader>b",
        function()
          require("snacks").picker.buffers()
        end,
        desc = "Buffers",
      },
      {
        "<leader>h",
        function()
          require("snacks").picker.help()
        end,
        desc = "Help",
      },
      {
        "<leader>a",
        function()
          require("snacks").lazygit.open()
        end,
        desc = "Lazygit",
      },
      {
        "<leader>/",
        function()
          require("snacks").picker.grep_buffers()
        end,
        desc = "Grep Buffers",
      },
      {
        "<leader>,",
        function()
          require("snacks").picker.recent()
        end,
        desc = "Recent Files",
      },
      -- Terminal
      {
        "<C-\\>",
        function()
          require("snacks").terminal.toggle()
        end,
        desc = "Toggle Terminal",
      },
      -- Zen
      {
        "<leader>z",
        function()
          require("snacks").zen()
        end,
        desc = "Zen Mode",
      },
      -- Utility
      {
        "<leader>cR",
        function()
          require("snacks").rename.rename_file()
        end,
        desc = "Rename File",
      },
      {
        "<leader>un",
        function()
          require("snacks").notifier.hide()
        end,
        desc = "Dismiss All Notifications",
      },
      {
        "<leader>nh",
        function()
          require("snacks").notifier.show_history()
        end,
        desc = "Notification History",
      },
    },
  },
}

return {
  {
    "matze/vim-move",
    config = function()
      vim.g.move_key_modifier = "A"
      vim.g.move_key_modifier_visualmode = "A"
    end,
  },
  {
    "folke/flash.nvim",
    event = "VeryLazy",
    opts = {
      labels = "asdfghjklqwertyuiopzxcvbnm",
      highlight = {
        backdrop = true,
      },
      modes = {
        char = {
          -- Keep flash ft motions, but leave `T` for tabnew keymap in keymaps.lua.
          keys = { "f", "F", "t", ";", "," },
        },
      },
    },
    keys = {
      { "s", mode = { "n", "x", "o" }, function() require("flash").jump() end, desc = "Flash" },
      { "S", mode = { "n", "x", "o" }, function() require("flash").treesitter() end, desc = "Flash Treesitter" },
      { "r", mode = "o", function() require("flash").remote() end, desc = "Remote Flash" },
    },
  },
  {
    "folke/todo-comments.nvim",
    event = "VeryLazy",
    dependencies = { "nvim-lua/plenary.nvim" },
    opts = {
      keywords = {
        TODO = { color = "#6b8dd6" },
        FIX = { color = "#f3a0bb" },
        NOTE = { color = "#d6bddb" },
      },
    },
    keys = {
      { "]t", function() require("todo-comments").jump_next() end, desc = "Next TODO" },
      { "[t", function() require("todo-comments").jump_prev() end, desc = "Prev TODO" },
      { "<leader>xt", "<cmd>Trouble todo toggle<cr>", desc = "TODOs (Trouble)" },
      { "<leader>ft", function() Snacks.picker.todo_comments() end, desc = "Search TODOs" },
    },
  },
}

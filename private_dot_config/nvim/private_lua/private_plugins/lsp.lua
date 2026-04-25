return {
  {
    "https://git.sr.ht/~whynothugo/lsp_lines.nvim",
    event = "LspAttach",
    config = function()
      require("lsp_lines").setup()
      vim.diagnostic.config({
        virtual_text = false,
        virtual_lines = true,
      })
    end,
  },
  {
    "williamboman/mason.nvim",
    cmd = { "Mason", "MasonInstall", "MasonUpdate", "MasonLog" },
    config = function()
      require("mason").setup()
    end,
  },
  {
    "neovim/nvim-lspconfig",
    event = { "BufReadPre", "BufNewFile" },
    config = function()
      require("config.nvim-lspconfig")
    end,
  },
  { "SmiteshP/nvim-navic" },
  {
    "folke/trouble.nvim",
    event = "VeryLazy",
    config = function()
      local trouble = require("trouble")
      trouble.setup({
        auto_preview = true,
        auto_refresh = true,
        win = {
          position = "bottom",
          height = 10,
        },
      })
      vim.keymap.set("n", "<leader>xx", "<cmd>Trouble diagnostics toggle<cr>", { desc = "Diagnostics (Trouble)" })
      vim.keymap.set(
        "n",
        "<leader>xX",
        "<cmd>Trouble diagnostics toggle filter.buf=0<cr>",
        { desc = "Buffer Diagnostics (Trouble)" }
      )
      vim.keymap.set("n", "<leader>cs", "<cmd>Trouble symbols toggle focus=false<cr>", { desc = "Symbols (Trouble)" })
      vim.keymap.set(
        "n",
        "<leader>cl",
        "<cmd>Trouble lsp toggle focus=false win.position=right<cr>",
        { desc = "LSP Definitions / references / ... (Trouble)" }
      )
      vim.keymap.set("n", "<leader>xL", "<cmd>Trouble loclist toggle<cr>", { desc = "Location List (Trouble)" })
      vim.keymap.set("n", "<leader>xQ", "<cmd>Trouble qflist toggle<cr>", { desc = "Quickfix List (Trouble)" })
    end,
  },
  {
    "stevearc/aerial.nvim",
    event = "VeryLazy",
    opts = {
      backends = { "treesitter", "lsp" },
      layout = {
        default_direction = "right",
        min_width = 30,
      },
    },
    keys = {
      { "<leader>co", "<cmd>AerialToggle!<cr>", desc = "Toggle Outline" },
      { "{", "<cmd>AerialPrev<cr>", desc = "Previous Symbol" },
      { "}", "<cmd>AerialNext<cr>", desc = "Next Symbol" },
    },
  },
}

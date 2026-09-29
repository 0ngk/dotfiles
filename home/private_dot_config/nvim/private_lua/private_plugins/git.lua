return {
  {
    "lewis6991/gitsigns.nvim",
    event = "VeryLazy",
    config = function()
      require("gitsigns").setup({
        on_attach = function(bufnr)
          local gs = require("gitsigns")
          local keymap = vim.keymap.set

          -- Navigation
          keymap("n", "g]", function()
            gs.nav_hunk("next")
          end, { buffer = bufnr, desc = "Next Hunk" })
          keymap("n", "g[", function()
            gs.nav_hunk("prev")
          end, { buffer = bufnr, desc = "Prev Hunk" })

          -- Toggle
          keymap("n", "gh", gs.toggle_linehl, { buffer = bufnr, desc = "Toggle Line Highlight" })
          keymap("n", "gp", gs.preview_hunk, { buffer = bufnr, desc = "Preview Hunk" })
        end,
      })
    end,
  },
}

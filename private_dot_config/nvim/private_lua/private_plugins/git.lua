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
          keymap("n", "g]", function() gs.nav_hunk("next") end, { buffer = bufnr, desc = "Next Hunk" })
          keymap("n", "g[", function() gs.nav_hunk("prev") end, { buffer = bufnr, desc = "Prev Hunk" })

          -- Actions
          keymap("n", "<leader>gs", gs.stage_hunk, { buffer = bufnr, desc = "Stage Hunk" })
          keymap("n", "<leader>gr", gs.reset_hunk, { buffer = bufnr, desc = "Reset Hunk" })
          keymap("v", "<leader>gs", function() gs.stage_hunk({ vim.fn.line("."), vim.fn.line("v") }) end, { buffer = bufnr, desc = "Stage Hunk" })
          keymap("v", "<leader>gr", function() gs.reset_hunk({ vim.fn.line("."), vim.fn.line("v") }) end, { buffer = bufnr, desc = "Reset Hunk" })
          keymap("n", "<leader>gS", gs.stage_buffer, { buffer = bufnr, desc = "Stage Buffer" })
          keymap("n", "<leader>gu", gs.undo_stage_hunk, { buffer = bufnr, desc = "Undo Stage Hunk" })
          keymap("n", "<leader>gd", gs.diffthis, { buffer = bufnr, desc = "Diff This" })
          keymap("n", "<leader>gb", function() gs.blame_line({ full = true }) end, { buffer = bufnr, desc = "Blame Line" })

          -- Toggle
          keymap("n", "gh", gs.toggle_linehl, { buffer = bufnr, desc = "Toggle Line Highlight" })
          keymap("n", "gp", gs.preview_hunk, { buffer = bufnr, desc = "Preview Hunk" })
        end,
      })
    end,
  },
}

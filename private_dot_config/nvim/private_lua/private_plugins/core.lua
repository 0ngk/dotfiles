return {
  -- Core Utilities
  { "dstein64/vim-startuptime" },
  { "vim-denops/denops.vim" },
  { "nvim-lua/plenary.nvim" },
  { "tani/vim-artemis" }, -- Compatibility between Vim and Neovim
  { "tpope/vim-surround" },
  { "jghauser/mkdir.nvim" },
  {
    "nacro90/numb.nvim", -- Line number preview
    config = function()
      require("numb").setup()
    end,
  },
  { "uga-rosa/ccc.nvim" }, -- Color picker
  { "brianhuster/live-preview.nvim" },
  { "wakatime/vim-wakatime", lazy = false },
  {
    "folke/which-key.nvim",
    event = "VeryLazy",
    opts = {
      win = { wo = { winblend = 40 } },
      spec = {
        { "<leader>d", group = "Debug" },
        { "<leader>t", group = "Test" },
        { "<leader>g", group = "Grep/Git" },
        { "<leader>x", group = "Trouble" },
        { "<leader>c", group = "Code" },
        { "<leader>o", group = "AI" },
      },
    },
  },
}

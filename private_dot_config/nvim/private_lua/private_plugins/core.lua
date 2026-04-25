return {
  -- Core Utilities
  { "dstein64/vim-startuptime", cmd = "StartupTime" },
  { "vim-denops/denops.vim" },
  { "nvim-lua/plenary.nvim" },
  { "tani/vim-artemis" }, -- Compatibility between Vim and Neovim
  { "tpope/vim-surround", lazy = false },
  { "jghauser/mkdir.nvim", lazy = false },
  {
    "nacro90/numb.nvim", -- Line number preview
    lazy = false,
    config = function()
      require("numb").setup()
    end,
  },
  { "uga-rosa/ccc.nvim", lazy = false }, -- Color picker
  { "brianhuster/live-preview.nvim", cmd = "LivePreview" },
  { "wakatime/vim-wakatime", event = "VeryLazy" },
  {
    "folke/which-key.nvim",
    event = "VeryLazy",
    opts = {
      win = { wo = { winblend = 40 } },
      spec = {
        { "<leader>d", group = "Debug" },
        { "<leader>t", group = "Test" },
        { "<leader>T", group = "Tabpage" },
        { "<leader>x", group = "Trouble" },
        { "<leader>c", group = "Code" },
        { "<leader>B", group = "Bufferline" },
        { "<leader>o", group = "AI" },
      },
    },
  },
}

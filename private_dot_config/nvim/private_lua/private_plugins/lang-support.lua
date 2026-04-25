return {
  -- Common Lisp
  { "vlime/vlime", rtp = "vim", ft = "lisp" },

  -- Clojure
  { "tpope/vim-fireplace", ft = "clojure" },

  -- Rust
  { "rust-lang/rust.vim", ft = "rust" },
  {
    "cordx56/rustowl",
    version = "*",
    ft = "rust",
    build = "cargo binstall rustowl",
    opts = {
      client = {
        on_attach = function(_, buffer)
          vim.keymap.set("n", "<leader>o", function()
            require("rustowl").toggle(buffer)
          end, { buffer = buffer, desc = "Toggle RustOwl" })
        end,
      },
    },
  },

  -- Go
  {
    "ray-x/go.nvim",
    ft = { "go", "gomod", "gowork", "gotmpl" },
    dependencies = { "ray-x/guihua.lua" },
    config = function()
      require("go").setup()
    end,
  },
  { "ray-x/guihua.lua" },
}

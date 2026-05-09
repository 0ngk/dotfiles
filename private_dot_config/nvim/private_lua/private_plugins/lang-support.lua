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

  -- C# / Unity
  {
    "seblyng/roslyn.nvim",
    ft = { "cs", "razor" },
    dependencies = { "neovim/nvim-lspconfig" },
    opts = {
      broad_search = true,
      lock_target = false,
      filewatching = "auto",
      choose_target = function(targets)
        if type(targets) ~= "table" or #targets == 0 then
          return nil
        end

        local function rank(path)
          local name = vim.fs.basename(path)
          if name == "Assembly-CSharp.sln" then
            return 0
          end
          if name == "Assembly-CSharp.slnx" then
            return 1
          end
          if name:match("%.sln$") then
            return 2
          end
          if name:match("%.slnx$") then
            return 3
          end
          if name:match("%.slnf$") then
            return 4
          end
          return 5
        end

        local sorted = vim.deepcopy(targets)
        table.sort(sorted, function(a, b)
          local ra = rank(a)
          local rb = rank(b)
          if ra == rb then
            return a < b
          end
          return ra < rb
        end)
        return sorted[1]
      end,
    },
  },

  -- Kotlin
  {
    "AlexandrosAlexiou/kotlin.nvim",
    ft = { "kotlin" },
    dependencies = {
      "williamboman/mason.nvim",
      "williamboman/mason-lspconfig.nvim",
      {
        "stevearc/oil.nvim",
        opts = {
          default_file_explorer = false,
        },
      },
      "folke/trouble.nvim",
    },
    config = function()
      local function detect_jdk_from_java()
        if vim.fn.executable("java") ~= 1 then
          return nil
        end

        local lines = vim.fn.systemlist("java -XshowSettings:properties -version 2>&1")

        for _, line in ipairs(lines) do
          local home = line:match("^%s*java%.home%s*=%s*(.-)%s*$")
          if home and home ~= "" then
            return home
          end
        end

        return nil
      end

      require("kotlin").setup({
        jdk_for_symbol_resolution = detect_jdk_from_java(),
      })
    end,
  },

  -- Typst
  {
    "chomosuke/typst-preview.nvim",
    ft = "typst",
    version = "1.*",
    opts = {},
  },
}

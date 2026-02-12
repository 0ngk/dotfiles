return {
  {
    "mhartington/formatter.nvim",
    config = function()
      local util = require("formatter.util")
      local augroup = vim.api.nvim_create_augroup
      local autocmd = vim.api.nvim_create_autocmd

      -- Format on save
      augroup("__formatter__", { clear = true })
      autocmd("BufWritePost", {
        group = "__formatter__",
        command = ":FormatWrite",
      })

      local biome = function()
        local util = require("formatter.util")
        local file_path = util.get_current_buffer_file_path()
        local project_root = vim.fn.getcwd()
        local rel_file_path = vim.fn.fnamemodify(file_path, ":.")
        local config_path = project_root .. "/biome.json"

        return {
          exe = "sh",
          args = {
            "-c",
            "cd "
              .. util.escape_path(project_root)
              .. " && biome check --format-with-errors true --write --config-path="
              .. util.escape_path(config_path)
              .. " --stdin-file-path="
              .. util.escape_path(rel_file_path),
          },
          stdin = true,
        }
      end

      local c_lang = function()
        return {
          exe = "clang-format",
          args = { "--assume-filename", util.get_current_buffer_file_path() },
          stdin = true,
        }
      end

      local sh = function()
        return {
          exe = "shfmt",
          args = { "-i", "2", "-ci", "-s" },
          stdin = true,
        }
      end
      require("formatter").setup({
        logging = true,
        log_level = vim.log.levels.WARN,
        filetype = {
          -- Any
          ["*"] = {
            require("formatter.filetypes.any").remove_trailing_whitespace,
          },

          -- Lua
          lua = {
            function()
              return {
                exe = "stylua",
                args = {
                  "--indent-type",
                  "Spaces",
                  "--indent-width",
                  "2",
                  "--search-parent-directories",
                  "--stdin-filepath",
                  util.escape_path(util.get_current_buffer_file_path()),
                  "--",
                  "-",
                },
                stdin = true,
              }
            end,
          },

          -- JS/TS/JSON
          javascript = { biome },
          javascriptreact = { biome },
          typescript = { biome },
          typescriptreact = { biome },
          json = { biome },
          jsonc = { biome },
          css = { biome },
          scss = { biome },
          sass = { biome },

          -- Python
          python = {
            function()
              return {
                exe = "ruff",
                args = {
                  "format",
                  "--stdin-filename",
                  util.escape_path(util.get_current_buffer_file_path()),
                  "-",
                },
                stdin = true,
              }
            end,
          },

          -- Gleam
          gleam = {
            function()
              return {
                exe = "gleam",
                args = { "format", "--stdin", util.get_current_buffer_file_path() },
                stdin = true,
              }
            end,
          },

          -- C/C++
          c = { c_lang },
          cpp = { c_lang },

          nix = {
            function()
              return {
                exe = "alejandra",
                stdin = true,
              }
            end,
          },

          sh = { sh },
          bash = { sh },
          zsh = { sh },

          kotlin = {
            function()
              return {
                exe = "ktlint",
                args = { "-F", "-" },
                stdin = true,
              }
            end,
          },
        },
      })
    end,
  },
}

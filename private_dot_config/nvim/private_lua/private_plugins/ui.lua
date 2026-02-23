return {
  { "echasnovski/mini.icons" },
  {
    "MeanderingProgrammer/render-markdown.nvim",
    config = function()
      require("render-markdown").setup({
        opts = {
          ft = { "markdown", "markdown.mdx", "Avante", "codecompanion" },
          file_types = { "markdown", "Avante", "codecompanion" },
        },
      })
    end,
  },
  { "nvim-tree/nvim-web-devicons" },
  { "MunifTanjim/nui.nvim" },
  {
    "EdenEast/nightfox.nvim",
    config = function()
      require("nightfox").setup({
        options = {
          transparent = true,
          styles = {
            comments = "italic",
            constants = "bold",
            functions = "bold",
            keywords = "bold",
            numbers = "italic",
            types = "italic,bold",
            variables = "bold",
          },
        },
        palettes = {
          carbonfox = {
            magenta = "#f3a0bb",
            pink = "#ffc4d6",
            cyan = "#d6bddb",
            blue = "#6b8dd6",

            bg0 = "NONE",
            bg1 = "NONE",
          },
        },
        groups = {
          all = {
            -- 透過背景の維持
            NormalFloat = { bg = "NONE" },
            FloatBorder = { bg = "NONE" },
            TelescopeNormal = { bg = "NONE" },
            TelescopeBorder = { bg = "NONE" },
            TelescopePromptNormal = { bg = "NONE" },
            TelescopePromptBorder = { bg = "NONE" },
            TelescopeResultsNormal = { bg = "NONE" },
            TelescopeResultsBorder = { bg = "NONE" },
            TelescopePreviewNormal = { bg = "NONE" },
            TelescopePreviewBorder = { bg = "NONE" },

            ["@keyword"] = { fg = "#ffc4d6", style = "bold" },
            ["@string"] = { fg = "#e9d9ee" },
            ["@function"] = { fg = "#6b8dd6", style = "bold" },
            ["@variable"] = { fg = "#d6bddb" },
            ["@comment"] = { fg = "#c9b3ce", style = "italic" },
            ["@constant"] = { fg = "#f3a0bb", style = "bold" },
            ["@conditional"] = { fg = "#ffc4d6", style = "bold" },
            ["@number"] = { fg = "#d6a0bb", style = "italic" },
            ["@operator"] = { fg = "#f3a0bb" },
            ["@type"] = { fg = "#4d6ba6", style = "italic,bold" },
          },
        },
      })
      vim.cmd("colorscheme carbonfox")
      vim.api.nvim_set_hl(0, "NormalFloat", { bg = "NONE" })
      vim.api.nvim_set_hl(0, "FloatBorder", { bg = "NONE" })
      vim.api.nvim_set_hl(0, "TelescopeNormal", { bg = "NONE" })
      vim.api.nvim_set_hl(0, "TelescopeBorder", { bg = "NONE" })
      vim.api.nvim_set_hl(0, "TelescopePromptNormal", { bg = "NONE" })
      vim.api.nvim_set_hl(0, "TelescopePromptBorder", { bg = "NONE" })
      vim.api.nvim_set_hl(0, "TelescopeResultsNormal", { bg = "NONE" })
      vim.api.nvim_set_hl(0, "TelescopeResultsBorder", { bg = "NONE" })
      vim.api.nvim_set_hl(0, "TelescopePreviewNormal", { bg = "NONE" })
      vim.api.nvim_set_hl(0, "TelescopePreviewBorder", { bg = "NONE" })
      -- Cursor/visual highlights
      -- vim.api.nvim_set_hl(0, "CursorLine", { bg = "#e9d9ee", blend = 30 })
      -- vim.api.nvim_set_hl(0, "CursorColumn", { bg = "#e9d9ee", blend = 30 })
      vim.api.nvim_set_hl(0, "Visual", { bg = "#ffc4d6", blend = 90 })
      -- Statusline font color to black
      vim.api.nvim_set_hl(0, "StatusLine", { fg = "#000000" })
      vim.api.nvim_set_hl(0, "StatusLineNC", { fg = "#000000" })
    end,
  },
  {
    "feline-nvim/feline.nvim",
    config = function()
      local feline = require("feline")
      local vi_mode = require("feline.providers.vi_mode")

      local colors = {
        pink = "#f3a0bb",
        pink_light = "#ffc4d6",
        pink_soft = "#d6a0bb",
        blue = "#2a5496",
        blue_light = "#6b8dd6",
        blue_soft = "#4d6ba6",
        lavender = "#d6bddb",
        lavender_light = "#e9d9ee",
        lavender_soft = "#c9b3ce",
        fg = "#ffffff",
        bg = "NONE",
        black = "#000000",
      }

      -- viモードカラー
      local vi_mode_colors = {
        NORMAL = colors.blue_light,
        INSERT = colors.pink_light,
        VISUAL = colors.lavender_light,
        BLOCK = colors.lavender,
        REPLACE = colors.pink,
        COMMAND = colors.blue_soft,
      }

      -- コンポーネント
      local components = {
        active = {
          {}, -- 左側
          {}, -- 中央
          {}, -- 右側
        },
        inactive = {
          {}, -- 左側
          {}, -- 右側
        },
      }

      -- 左側: viモード
      table.insert(components.active[1], {
        provider = function()
          return " " .. vi_mode.get_vim_mode() .. " "
        end,
        hl = function()
          return {
            fg = colors.black,
            bg = vi_mode_colors[vi_mode.get_vim_mode()] or colors.pink_light,
            style = "bold",
          }
        end,
        right_sep = {
          str = "",
          hl = function()
            return {
              fg = vi_mode_colors[vi_mode.get_vim_mode()] or colors.pink_light,
              bg = colors.bg,
            }
          end,
        },
      })

      -- 左側: ファイル情報
      table.insert(components.active[1], {
        provider = function()
          local filepath = vim.fn.expand("%:~:.")
          if filepath == "" then
            return " [No Name] "
          end
          local filename = vim.fn.expand("%:t")
          local icon = require("nvim-web-devicons").get_icon(filename, vim.fn.expand("%:e"), { default = true })
          return " " .. (icon or "") .. " " .. filepath .. " "
        end,
        hl = {
          fg = colors.lavender_soft,
          bg = colors.bg,
        },
      })

      -- 右側: Git情報
      table.insert(components.active[3], {
        provider = "git_branch",
        hl = {
          fg = colors.pink_soft,
          bg = colors.bg,
        },
        icon = " ",
        left_sep = " ",
      })

      -- 右側: LSP診断
      table.insert(components.active[3], {
        provider = function()
          local errors = #vim.diagnostic.get(0, { severity = vim.diagnostic.severity.ERROR })
          if errors > 0 then
            return " " .. errors .. " "
          end
          return ""
        end,
        hl = {
          fg = colors.pink,
          bg = colors.bg,
        },
        left_sep = " ",
      })

      table.insert(components.active[3], {
        provider = function()
          local warnings = #vim.diagnostic.get(0, { severity = vim.diagnostic.severity.WARN })
          if warnings > 0 then
            return " " .. warnings .. " "
          end
          return ""
        end,
        hl = {
          fg = colors.lavender,
          bg = colors.bg,
        },
      })

      -- 右側: 位置情報
      table.insert(components.active[3], {
        provider = function()
          local line = vim.fn.line(".")
          local col = vim.fn.col(".")
          return string.format(" %d:%d ", line, col)
        end,
        hl = {
          fg = colors.black,
          bg = colors.blue_light,
          style = "bold",
        },
        left_sep = {
          str = "",
          hl = {
            fg = colors.blue_light,
            bg = colors.bg,
          },
        },
      })

      -- 非アクティブウィンドウ
      table.insert(components.inactive[1], {
        provider = function()
          local filename = vim.fn.expand("%:t")
          if filename == "" then
            return " [No Name] "
          end
          return " " .. filename .. " "
        end,
        hl = {
          fg = colors.lavender_soft,
          bg = colors.bg,
        },
      })

      feline.setup({
        components = components,
        force_inactive = {
          filetypes = {
            "NvimTree",
            "neo-tree",
            "packer",
            "startify",
            "fugitive",
            "fugitiveblame",
            "qf",
            "help",
          },
        },
      })

      -- Winbar with navic breadcrumbs
      local winbar_components = {
        active = {
          {
            {
              provider = function()
                local navic = require("nvim-navic")
                if navic.is_available() then
                  return navic.get_location()
                end
                return ""
              end,
              hl = {
                fg = colors.lavender_soft,
                bg = colors.bg,
              },
              left_sep = " ",
            },
          },
        },
        inactive = {
          {},
        },
      }
      feline.winbar.setup({ components = winbar_components })
    end,
  },
  {
    "nanozuki/tabby.nvim",
    config = function()
      vim.api.nvim_set_hl(0, "TabLineCute", {
        fg = "#6b8dd6",
        bg = "NONE",
      })
      vim.api.nvim_set_hl(0, "TabLineSelCute", {
        fg = "#ffffff",
        bg = "#f3a0bb",
        bold = true,
      })
      vim.api.nvim_set_hl(0, "TabLineFillCute", {
        bg = "NONE",
      })
      vim.api.nvim_set_hl(0, "TabLineWinCute", {
        fg = "#d6bddb",
        bg = "NONE",
      })
      vim.api.nvim_set_hl(0, "TabLineHeadCute", {
        fg = "#ffffff",
        bg = "#d6bddb",
        bold = true,
      })

      local theme = {
        fill = "TabLineFillCute",
        head = "TabLineHeadCute",
        current_tab = "TabLineSelCute",
        tab = "TabLineCute",
        win = "TabLineWinCute",
        tail = "TabLineHeadCute",
      }

      require("tabby").setup({
        line = function(line)
          return {
            {
              { " 󰙴 ", hl = theme.head },
              line.sep("", theme.head, theme.fill),
            },
            line.tabs().foreach(function(tab)
              local hl = tab.is_current() and theme.current_tab or theme.tab
              return {
                line.sep("", hl, theme.fill),
                tab.is_current() and " " or " ",
                tab.number(),
                " ",
                tab.name(),
                " ",
                tab.close_btn("󰅖"),
                line.sep("", hl, theme.fill),
                hl = hl,
                margin = " ",
              }
            end),
            line.spacer(),
            line.wins_in_tab(line.api.get_current_tab()).foreach(function(win)
              return {
                line.sep("", theme.win, theme.fill),
                win.is_current() and " " or " ",
                win.buf_name(),
                " ",
                line.sep("", theme.win, theme.fill),
                hl = theme.win,
                margin = " ",
              }
            end),
            {
              line.sep("", theme.tail, theme.fill),
              { " 󰊠 ", hl = theme.tail },
            },
            hl = theme.fill,
          }
        end,
      })
    end,
  },
  {
    "folke/noice.nvim",
    config = function()
      require("noice").setup({
        cmdline = {
          enabled = true,
        },
        messages = {
          enabled = false,
        },
        notify = {
          enabled = true,
        },
        lsp = {
          override = {
            ["vim.lsp.util.convert_input_to_markdown_lines"] = true,
            ["vim.lsp.util.stylize_markdown"] = true,
          },
        },
        presets = {
          bottom_search = true,
          command_palette = true,
          long_message_to_split = true,
          inc_rename = false,
          lsp_doc_border = false,
        },
      })
    end,
  },
}

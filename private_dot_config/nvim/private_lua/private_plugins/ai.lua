return {
  {
    "ravitemer/mcphub.nvim",
    cmd = "MCPHub",
    config = function()
      require("mcphub").setup({
        cmd = vim.fn.expand("~") .. "/.local/share/pnpm/mcp-hub",
      })
    end,
  },
  { "github/copilot.vim", event = "InsertEnter" },
  {
    "olimorris/codecompanion.nvim",
    commit = "558518f8d78a44198cd428f6bf8bf48bfa38d76d",
    cmd = { "CodeCompanion", "CodeCompanionChat", "CodeCompanionAction" },
    dependencies = {
      "github/copilot.vim",
      "MunifTanjim/nui.nvim",
      "nvim-lua/plenary.nvim",
      "ravitemer/mcphub.nvim",
    },
    config = function()
      require("codecompanion").setup({
        adapters = {
          http = {
            copilot = function()
              return require("codecompanion.adapters").extend("copilot", {
                schema = {
                  max_tokens = {
                    default = 512000,
                  },
                  model = {
                    default = "claude-sonnet-4.5",
                  },
                },
              })
            end,
          },
        },
        display = {
          chat = {
            auto_scroll = true,
            show_header_separator = true,
            window = { position = "right", width = 0.4 },
          },
        },
        extensions = {
          mcphub = {
            callback = "mcphub.extensions.codecompanion",
            opts = {
              make_slash_commands = true,
              make_vars = true,
              requires_approval = true,
              show_result_in_chat = true,
            },
          },
        },
        opts = { log_level = "TRACE" },
        strategies = {
          chat = {
            adapter = "copilot",
            system_prompt = "You are a helpful programming assistant. Answer the user's questions as best as you can. If you are unsure of the answer, say 'I'm not sure' instead of making something up. The language you use to respond should be the same as the user's.",
            roles = {
              llm = function(adapter)
                local model_name = ""
                if adapter.parameters == nil then
                  model_name = adapter.schema.model.default
                else
                  model_name = adapter.schema.model.default
                end
                return "  CodeCompanion (" .. adapter.formatted_name .. " - " .. model_name .. ")"
              end,
              user = "  Me",
            },
            tools = { opts = { auto_submit_errors = true, auto_submit_success = true } },
          },
        },
      })
    end,
  },
}

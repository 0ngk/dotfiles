local lsp = require("config.fsharp.definition_lsp")
local navigation = require("config.fsharp.definition_navigation")

local M = {}

local function first_line(message)
  if type(message) ~= "string" then
    return nil
  end
  return message:match("([^\n]+)") or message
end

local function remember_error(error_message)
  if type(error_message) == "string" and error_message ~= "" then
    vim.g.fsac_last_definition_error = error_message
  end
end

local function jump_or_remember(locations, offset_encoding, title)
  local jumped, jump_error = navigation.jump_to_locations(locations, offset_encoding, title)
  if not jumped then
    remember_error(jump_error)
  end
  return jumped
end

function M.go_to_definition_with_fallback()
  local bufnr = vim.api.nvim_get_current_buf()
  if vim.bo[bufnr].filetype ~= "fsharp" then
    vim.lsp.buf.definition()
    return
  end

  local winid = vim.api.nvim_get_current_win()

  local definition_locations, definition_encoding, definition_error = lsp.request_definition_with_retry(bufnr, winid)
  if definition_locations and jump_or_remember(definition_locations, definition_encoding, "LSP Definitions") then
    return
  end
  remember_error(definition_error)

  if lsp.is_decompile_error(definition_error) then
    vim.notify(
      "fsautocomplete の decompile 失敗を検知したため、type definition にフォールバックします。",
      vim.log.levels.WARN,
      { title = "F# Definition" }
    )
  end

  local type_locations, type_encoding, type_error = lsp.request_locations(bufnr, winid, "textDocument/typeDefinition")
  if type_locations and jump_or_remember(type_locations, type_encoding, "LSP Type Definitions") then
    return
  end
  remember_error(type_error)

  local reference_locations, reference_encoding, reference_error =
    lsp.request_locations(bufnr, winid, "textDocument/references")
  if reference_locations then
    vim.notify(
      "definition が失敗したため、references 一覧を表示します。",
      vim.log.levels.WARN,
      { title = "F# Definition" }
    )
    if jump_or_remember(reference_locations, reference_encoding, "LSP References (Fallback)") then
      return
    end
  end
  remember_error(reference_error)

  local summary = first_line(vim.g.fsac_last_definition_error)
  if summary then
    vim.notify(("F# definition 失敗: %s"):format(summary), vim.log.levels.ERROR, { title = "F# Definition" })
  else
    vim.notify("F# definition が見つかりませんでした。", vim.log.levels.WARN, { title = "F# Definition" })
  end
end

function M.setup()
  if vim.g.__fsharp_definition_setup_done then
    return
  end
  vim.g.__fsharp_definition_setup_done = true

  vim.api.nvim_create_user_command("FSharpLastDefinitionError", function()
    local message = vim.g.fsac_last_definition_error
    if type(message) ~= "string" or message == "" then
      vim.notify("fsautocomplete の直近 definition エラーはありません。", vim.log.levels.INFO, {
        title = "F# Definition",
      })
      return
    end
    vim.notify(message, vim.log.levels.ERROR, { title = "F# Last Definition Error" })
  end, { desc = "Show the last fsautocomplete definition error" })
end

return M

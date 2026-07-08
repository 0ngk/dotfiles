local fsharp_definition = require("config.fsharp.definition")

fsharp_definition.setup()

local M = {}

local function enable_inlay_hints(client, bufnr)
  if client:supports_method("textDocument/inlayHint", bufnr) then
    vim.lsp.inlay_hint.enable(true, { bufnr = bufnr })
  end
end

local register_capability = vim.lsp.handlers["client/registerCapability"]
vim.lsp.handlers["client/registerCapability"] = function(err, result, ctx, config)
  local response
  if register_capability then
    response = register_capability(err, result, ctx, config)
  end
  if err or not result or not result.registrations then
    return response
  end

  local has_inlay_hint_registration = vim.iter(result.registrations):any(function(registration)
    return registration.method == "textDocument/inlayHint"
  end)
  if not has_inlay_hint_registration then
    return response
  end

  if not ctx or not ctx.client_id then
    return response
  end

  local client = vim.lsp.get_client_by_id(ctx.client_id)
  if not client then
    return response
  end

  for bufnr in pairs(client.attached_buffers or {}) do
    enable_inlay_hints(client, bufnr)
  end

  return response
end

function M.on_attach(client, bufnr)
  vim.keymap.set("n", "gd", function()
    fsharp_definition.go_to_definition_with_fallback()
  end, { buffer = bufnr, desc = "Go to Definition" })
  vim.keymap.set("n", ">", function()
    vim.lsp.buf.hover()
  end, { buffer = bufnr, desc = "Hover Documentation" })
  vim.keymap.set("n", "gi", vim.lsp.buf.implementation, { buffer = bufnr, desc = "Go to Implementation" })
  vim.keymap.set("n", "<leader>rn", vim.lsp.buf.rename, { buffer = bufnr, desc = "Rename" })
  vim.keymap.set({ "n", "v" }, "<leader>ca", vim.lsp.buf.code_action, { buffer = bufnr, desc = "Code Action" })

  -- inlay hint
  enable_inlay_hints(client, bufnr)

  -- fsautocomplete can occasionally spin on semantic tokens/inlay updates.
  -- Disable semantic tokens on attach for stability.
  if client.name == "fsautocomplete" then
    client.server_capabilities.semanticTokensProvider = nil
  end

  -- nvim-navic breadcrumbs
  if client.server_capabilities.documentSymbolProvider then
    require("nvim-navic").attach(client, bufnr)
  end
end

M.capabilities = vim.tbl_deep_extend("force", require("blink.cmp").get_lsp_capabilities(), {
  textDocument = {
    definition = {
      dynamicRegistration = false,
      linkSupport = true,
    },
    foldingRange = {
      dynamicRegistration = false,
      lineFoldingOnly = true,
    },
  },
  offsetEncoding = { "utf-8", "utf-16" },
})

return M

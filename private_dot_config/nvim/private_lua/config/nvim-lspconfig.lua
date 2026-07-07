local lsp_common = require("config.lsp-common")
local dotnet = require("config.lsp.dotnet")
local servers = require("config.lsp.servers")

require("config.lsp.filetypes").setup()
require("config.lsp.deno").setup()
dotnet.setup()

servers.setup({
  on_attach = lsp_common.on_attach,
  capabilities = lsp_common.capabilities,
  roslyn_on_attach = function(client, bufnr)
    lsp_common.on_attach(client, bufnr)
    dotnet.notify_unity_roslyn_project_state(client, bufnr)
  end,
  fsautocomplete_cmd_env = dotnet.fsautocomplete_cmd_env(),
})

vim.lsp.enable(servers.enabled)

local M = {}

function M.setup()
  vim.api.nvim_create_autocmd("BufReadCmd", {
    group = vim.api.nvim_create_augroup("UserDenoVirtualTextDocument", { clear = true }),
    pattern = "deno:/*",
    callback = function(event)
      local buf = event.buf
      local uri = event.match

      local clients = vim.lsp.get_clients({ name = "denols" })
      if #clients == 0 then
        return
      end

      local result = clients[1]:request_sync("deno/virtualTextDocument", {
        textDocument = { uri = uri },
      }, 5000)

      if result and result.result then
        local lines = vim.split(result.result, "\n", { plain = true })
        vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
      end

      vim.bo[buf].modifiable = false
      vim.bo[buf].modified = false
      vim.bo[buf].readonly = true
      vim.bo[buf].filetype = "typescript"
    end,
  })
end

return M

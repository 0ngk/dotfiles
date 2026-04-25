return {
  {
    "olimorris/persisted.nvim",
    event = "VimEnter",
    config = function()
      local save_dir = vim.fn.stdpath("data") .. "/sessions/"
      -- Ensure sessions directory exists
      if vim.fn.isdirectory(save_dir) == 0 then
        vim.fn.mkdir(save_dir, "p")
      end
      local persisted = require("persisted")

      persisted.setup({
        save_dir = save_dir,
        follow_cwd = true,
        use_git_branch = true,
        autoload = true,
        should_save = function()
          for _, bufnr in ipairs(vim.api.nvim_list_bufs()) do
            if vim.api.nvim_buf_is_valid(bufnr) and vim.bo[bufnr].buflisted and vim.bo[bufnr].buftype == "" then
              local filetype = vim.bo[bufnr].filetype
              if filetype ~= "alpha" and filetype ~= "lazy" and filetype ~= "noice" and filetype ~= "notify" then
                if vim.api.nvim_buf_get_name(bufnr) ~= "" or vim.bo[bufnr].modified then
                  return true
                end
              end
            end
          end
          return false
        end,
      })

      -- `event = "VimEnter"` で遅延読み込みしているため、
      -- persisted.nvim 側の VimEnter autocmd より後に読み込まれるケースがある。
      -- その場合でも起動時復元を確実に行うため、ここで明示的に autoload する。
      persisted.autoload()
    end,
  },
}

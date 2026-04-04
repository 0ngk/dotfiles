local keymap = vim.keymap.set
local workspaces = require("config.tab_workspaces")

local function smart_close()
  local current_buf = vim.api.nvim_get_current_buf()
  if workspaces.is_normal_buffer(current_buf) and vim.bo[current_buf].modified then
    vim.notify("Buffer has unsaved changes", vim.log.levels.WARN)
    return
  end

  local current_tab = vim.api.nvim_get_current_tabpage()
  local windows = vim.tbl_filter(function(win)
    return vim.api.nvim_win_get_config(win).relative == ""
  end, vim.api.nvim_tabpage_list_wins(current_tab))

  if #windows > 1 then
    vim.cmd("q")
    return
  end

  if workspaces.is_normal_buffer(current_buf) and workspaces.workspace_buffer_count(current_tab) > 1 then
    workspaces.close_workspace_buffer(current_buf, current_tab)
    return
  end

  if #vim.api.nvim_list_tabpages() > 1 then
    workspaces.close_workspace(current_tab)
    return
  end

  vim.cmd("q")
end

-- Key
keymap("i", "<Right>", "->")
keymap("i", "<S-Right>", "=>")
keymap("i", "<Left>", "<-")
keymap("i", "<S-Left>", "<=")
keymap("i", "<Up>", "|>")
keymap("i", "<Down>", "<>")
keymap("n", "<Left>", "<<", { silent = true })
keymap("v", "<Left>", "<", { silent = true })
keymap("n", "<Right>", ">>", { silent = true })
keymap("v", "<Right>", ">", { silent = true })
keymap("n", "q", "<Nop>")

-- Insert modeを抜けたら英数入力に切り替え
vim.api.nvim_create_autocmd("InsertLeave", {
  callback = function()
    vim.fn.system("im-select com.apple.keylayout.UnicodeHexInput")
  end,
})
keymap("i", "<Esc>", "<Esc>", { silent = true })

-- Basic
keymap("i", "jk", "<Esc>", { silent = true })
keymap("i", "jj", "<Esc>", { silent = true })
keymap("n", "<F2>", "zr<cr>", { silent = true }) -- 展開
keymap("n", "<F3>", ":vs<cr>", { silent = true }) -- 水平に分割
keymap("n", "<F4>", ":sp<cr>", { silent = true }) -- 垂直に分割
keymap("n", "<leader>s", ":w<cr>", { silent = true }) -- 保存
keymap("n", "W", ":noautocmd w<cr>", { silent = true }) -- 保存（autocmdを無効化）
keymap("n", "<leader>w", smart_close, { silent = true, desc = "Smart Close Window or Buffer" }) -- 状況に応じてウィンドウ、バッファ、Neovimを閉じる
keymap("n", "<leader>q", ":qa<cr>", { silent = true }) -- 全てのウィンドウを閉じる

-- Window
keymap("n", "<C-l>", "<C-w>w", { silent = true }) -- ウィンドウ移動
keymap("n", "<C-h>", "<C-w>W", { silent = true }) -- ウィンドウ移動
keymap("n", "<C-k>", ":vs<cr>", { silent = true }) -- ウィンドウを水平に分割
keymap("n", "<C-j>", ":sp<cr>", { silent = true }) -- ウィンドウを水平に分割

-- Tab
keymap("n", "N", "<cmd>tabnew<cr>", { silent = true, desc = "Tabpage New" })
keymap("n", "J", "<cmd>tabprevious<cr>", { silent = true, desc = "Tabpage Previous" })
keymap("n", "K", "<cmd>tabnext<cr>", { silent = true, desc = "Tabpage Next" })
keymap("n", "M", "N", { silent = true, desc = "Search Previous Match" })
keymap("n", "<lt>", "J", { silent = true, desc = "Join Lines" })
keymap("n", ">", "K", { silent = true, desc = "Keyword Lookup" })
keymap("n", "<S-l>", "<cmd>BufferLineCycleNext<cr>", { silent = true }) -- 次のバッファ
keymap("n", "<S-h>", "<cmd>BufferLineCyclePrev<cr>", { silent = true }) -- 前のバッファ
keymap("n", "<S-t>", "<cmd>enew<cr>", { silent = true }) -- 新しいバッファ
keymap("n", "<leader>Bn", "<cmd>BufferLineCycleNext<cr>", { silent = true, desc = "Bufferline Next" })
keymap("n", "<leader>Bp", "<cmd>BufferLineCyclePrev<cr>", { silent = true, desc = "Bufferline Previous" })
keymap("n", "<leader>Bh", "<cmd>BufferLineMovePrev<cr>", { silent = true, desc = "Bufferline Move Left" })
keymap("n", "<leader>Bl", "<cmd>BufferLineMoveNext<cr>", { silent = true, desc = "Bufferline Move Right" })
keymap("n", "<leader>BP", "<cmd>BufferLinePick<cr>", { silent = true, desc = "Bufferline Pick" })
keymap("n", "<leader>Bt", "<cmd>BufferLineTogglePin<cr>", { silent = true, desc = "Bufferline Toggle Pin" })
keymap("n", "<leader>bd", function()
  workspaces.close_workspace_buffer()
end, { silent = true, desc = "Workspace Buffer Close" })
keymap("n", "<leader>bD", function()
  workspaces.global_delete_buffer()
end, { silent = true, desc = "Global Buffer Delete" })
keymap("n", "<leader>Tt", "<cmd>tabnew<cr>", { silent = true, desc = "Tabpage New" })
keymap("n", "<leader>Tn", "<cmd>tabnext<cr>", { silent = true, desc = "Tabpage Next" })
keymap("n", "<leader>Tp", "<cmd>tabprevious<cr>", { silent = true, desc = "Tabpage Previous" })
keymap("n", "<leader>Tr", "<cmd>WorkspaceRename<cr>", { silent = true, desc = "Workspace Rename" })
keymap("n", "<leader>Tx", function()
  workspaces.close_workspace()
end, { silent = true, desc = "Workspace Close" })

for index = 1, 9 do
  keymap("n", "<leader>" .. index, ("<cmd>BufferLineGoToBuffer %d<cr>"):format(index), {
    silent = true,
    desc = ("Bufferline Go To %d"):format(index),
  })
end
keymap("n", "<leader>0", "<cmd>BufferLineGoToBuffer -1<cr>", {
  silent = true,
  desc = "Bufferline Go To Last",
})

-- Fern
keymap("n", "<Leader>r", ":Fern . -reveal=% -drawer<cr>", { silent = true })
keymap("n", "<Leader>e", ":Fern . -reveal=%<cr>", { silent = true })

-- LSP keymaps (using snacks.picker)
keymap("n", "<Tab>", function()
  Snacks.picker.lsp_definitions()
end, { silent = true, desc = "LSP Go to Definition" })
keymap("n", "<leader><Tab>", function()
  vim.lsp.buf.hover()
end, { silent = true, desc = "LSP Hover Documentation" })
keymap("n", "<S-Tab>", function()
  Snacks.picker.lsp_references()
end, { silent = true, desc = "LSP References" })

-- Rust
vim.api.nvim_create_autocmd("FileType", {
  pattern = "rust",
  callback = function()
    keymap({ "i", "n" }, "<F11>", ":Cargo run<cr>")
  end,
})

-- live-preview.nvim
keymap("n", "<leader>lp", ":LivePreview start<cr>", { desc = "Live Preview" })

-- codecompanion
keymap({ "n", "v" }, "<leader>oc", ":CodeCompanionChat<cr>")
keymap({ "n", "v" }, "<leader>oa", ":CodeCompanionAction<cr>")

-- denippet.vim
keymap("i", "<C-l>", "<Plug>(denippet-expand)", { desc = "Expand snippet" })
vim.keymap.set("n", "<C-i>", "<C-i>")

local keymap = vim.keymap.set

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
keymap("n", "<leader>w", ":q<cr>", { silent = true }) -- ウィンドウを閉じる
keymap("n", "<leader>q", ":qa<cr>", { silent = true }) -- 全てのウィンドウを閉じる

-- Window
keymap("n", "<C-l>", "<C-w>w", { silent = true }) -- ウィンドウ移動
keymap("n", "<C-h>", "<C-w>W", { silent = true }) -- ウィンドウ移動
keymap("n", "<C-k>", ":vs<cr>", { silent = true }) -- ウィンドウを水平に分割
keymap("n", "<C-j>", ":sp<cr>", { silent = true }) -- ウィンドウを水平に分割

-- Tab
keymap("n", "<S-l>", ":tabnext<cr>", { silent = true }) -- 次のタブ
keymap("n", "<S-h>", ":tabprevious<cr>", { silent = true }) -- 前のタブ
keymap("n", "<S-t>", "<cmd>tabnew<cr>", { silent = true }) -- 新しいタブ

-- LSP keymaps (using snacks.picker)
keymap("n", "<Tab>", function() Snacks.picker.lsp_definitions() end, { silent = true, desc = "LSP Go to Definition" })
keymap("n", "<leader><Tab>", vim.lsp.buf.hover, { silent = true, desc = "LSP Hover Documentation" })
keymap("n", "<S-Tab>", function() Snacks.picker.lsp_references() end, { silent = true, desc = "LSP References" })

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

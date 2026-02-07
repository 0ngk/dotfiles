local keymap = vim.keymap.set
local builtin = require("telescope.builtin")

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
-- keymap("n", "<leader>Q", ":q!<cr>", { silent = true }) -- 強制終了
keymap("n", "<leader>q", ":qa<cr>", { silent = true }) -- 全てのウィンドウを閉じる

-- Window
keymap("n", "<C-l>", "<C-w>w", { silent = true }) -- ウィンドウ移動
keymap("n", "<C-h>", "<C-w>W", { silent = true }) -- ウィンドウ移動
keymap("n", "<C-k>", ":vs<cr>", { silent = true }) -- ウィンドウを水平に分割
keymap("n", "<C-j>", ":sp<cr>", { silent = true }) -- ウィンドウを水平に分割

-- Tab
keymap("n", "<S-l>", ":tabnext<cr>", { silent = true }) -- 次のタブ
keymap("n", "<S-h>", ":tabprevious<cr>", { silent = true }) -- 前のタブ
keymap("n", "<S-t>", ":tabnew<cr>", { silent = true }) -- 新しいタブ

-- Jetpack
keymap("n", "<F5>", ":JetpackSync<cr>", { silent = true }) -- Jetpack Sync

-- Fern
keymap("n", "<Leader>r", ":Fern . -reveal=% -drawer<cr>", { silent = true })
keymap("n", "<Leader>e", ":Fern . -reveal=%<cr>", { silent = true })

-- LSP keymaps
-- keymap("n", "<Tab>", vim.lsp.buf.definition, { silent = true, desc = "LSP Go to Definition" })
keymap("n", "<Tab>", ":Telescope lsp_definitions<cr>", { silent = true, desc = "LSP Go to Definition" })
keymap("n", "<leader><Tab>", vim.lsp.buf.hover, { silent = true, desc = "LSP Hover Documentation" })
keymap("n", "<S-Tab>", ":Telescope lsp_references<cr>", { silent = true, desc = "LSP Go to lsp_references" })

-- Rust
vim.api.nvim_create_autocmd("FileType", {
  pattern = "rust",
  callback = function()
    keymap({ "i", "n" }, "<F11>", ":Cargo run<cr>")
  end,
})

-- jump cursor
keymap("n", "<space>j", "<Plug>(jumpcursor-jump)")

-- GitGutter
keymap("n", "gh", ":GitGutterLineHighlightsToggle<cr>")
keymap("n", "gp", ":GitGutterPreviewHunk<cr>")
keymap("n", "g[", ":GitGutterPrevHunk<cr>")
keymap("n", "g]", ":GitGutterNextHunk<cr>")

-- telescope.nvim
keymap("n", "<leader>f", builtin.find_files, { desc = "Telescope find files" })
keymap("n", "<leader>g", builtin.live_grep, { desc = "Telescope live grep" })
keymap("n", "<leader>b", builtin.buffers, { desc = "Telescope buffers" })
keymap("n", "<leader>h", builtin.help_tags, { desc = "Telescope help tags" })

-- live-preview.nvim
keymap("n", "<leader>lp", ":LivePreview start<cr>", { desc = "Live Preview" })

-- codecompanion
keymap({ "n", "v" }, "<leader>oc", ":CodeCompanion<cr>")
keymap({ "n", "v" }, "<leader>oc", ":CodeCompanionChat<cr>")
keymap({ "n", "v" }, "<leader>oa", ":CodeCompanionAction<cr>")

-- denippet.vim
--
-- 展開
keymap("i", "<C-l>", "<Plug>(denippet-expand)", { desc = "Expand snippet" })
vim.keymap.set("n", "<C-i>", "<C-i>")
-- -- 次のスニペットジャンプ（Tab）
-- keymap("i", "<Tab>", [[denippet#jumpable() ? '<Plug>(denippet-jump-next)' : '<Tab>']], { expr = true, noremap = true, desc = "Snippet jump next (i)" })
-- keymap("s", "<Tab>", [[denippet#jumpable() ? '<Plug>(denippet-jump-next)' : '<Tab>']], { expr = true, noremap = true, desc = "Snippet jump next (s)" })
--
-- -- 前のスニペットジャンプ（Shift-Tab）
-- keymap("i", "<S-Tab>", [[denippet#jumpable(-1) ? '<Plug>(denippet-jump-prev)' : '<S-Tab>']], { expr = true, noremap = true, desc = "Snippet jump prev (i)" })
-- keymap("s", "<S-Tab>", [[denippet#jumpable(-1) ? '<Plug>(denippet-jump-prev)' : '<S-Tab>']], { expr = true, noremap = true, desc = "Snippet jump prev (s)" })

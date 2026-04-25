local opt = vim.opt
local g = vim.g

-- Misc
opt.updatetime = 100
opt.cursorline = true
opt.cursorcolumn = true
opt.laststatus = 3
opt.termguicolors = true
opt.clipboard = "unnamedplus"
opt.viminfofile = "NONE"
opt.encoding = "utf-8"
opt.fileencoding = "uft-8"
-- 行番号
opt.number = true
opt.relativenumber = true
-- スペル
opt.spell = true
-- フォルド
opt.foldmethod = "marker"
-- インデント
opt.autoindent = true
opt.smartindent = true
opt.expandtab = true
opt.tabstop = 2
opt.softtabstop = 2
opt.shiftwidth = 2
-- 背景透過
opt.winblend = 40 -- ウィンドウの不透明度
-- opt.pumblend = 100 -- ポップアップメニューの不透明度
-- 空行のチルダを非表示
opt.fillchars = { eob = " " }

g.mapleader = " "
local deno = vim.fn.exepath("deno")
if deno ~= "" then
  g["denops#deno"] = deno
end

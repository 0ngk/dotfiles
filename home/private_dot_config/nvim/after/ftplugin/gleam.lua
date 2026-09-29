-- Use nvim-treesitter indentation for Gleam.
if pcall(require, "nvim-treesitter") then
  vim.bo.indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
  vim.b.undo_ftplugin = (vim.b.undo_ftplugin or "") .. "|setlocal indentexpr<"
end

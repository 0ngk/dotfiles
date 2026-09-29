local api = vim.api

local whitespace_patterns = {
  FullWidthSpace = [[　]],
  TrailingSpace = [[\s\+$]],
}

local function set_whitespace_highlights()
  api.nvim_set_hl(0, "FullWidthSpace", { fg = "#111111", bg = "#ff7070", bold = true })
  api.nvim_set_hl(0, "TrailingSpace", { fg = "#111111", bg = "#ff7070", bold = true })
end

local function clear_whitespace_matches()
  local ok, matches = pcall(vim.fn.getmatches)
  if not ok then
    return
  end

  for _, match in ipairs(matches) do
    if whitespace_patterns[match.group] then
      pcall(vim.fn.matchdelete, match.id)
    end
  end
end

local function apply_whitespace_matches()
  clear_whitespace_matches()

  for group, pattern in pairs(whitespace_patterns) do
    vim.fn.matchadd(group, pattern)
  end
end

local whitespace_augroup = api.nvim_create_augroup("WhitespaceHighlight", { clear = true })

api.nvim_create_autocmd("ColorScheme", {
  group = whitespace_augroup,
  callback = set_whitespace_highlights,
})

api.nvim_create_autocmd({ "VimEnter", "BufWinEnter", "WinEnter", "InsertLeave" }, {
  group = whitespace_augroup,
  callback = apply_whitespace_matches,
})

set_whitespace_highlights()
apply_whitespace_matches()

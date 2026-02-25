return {
  {
    "lambdalisue/fern.vim",
    init = function()
      local g = vim.g
      g["fern#renderer"] = "nerdfont"
      g["fern#default_hidden"] = true
    end,
    config = function()
      vim.cmd([[
        augroup my-glyph-palette
          autocmd! *
          autocmd FileType fern call glyph_palette#apply()
          autocmd FileType nerdtree,startify call glyph_palette#apply()
        augroup END

        function! s:fern_settings() abort
          nmap <silent> <buffer> p     <Plug>(fern-action-preview:toggle)
          nmap <silent> <buffer> <C-p> <Plug>(fern-action-preview:auto:toggle)
          nmap <silent> <buffer> <C-d> <Plug>(fern-action-preview:scroll:down:half)
          nmap <silent> <buffer> <C-u> <Plug>(fern-action-preview:scroll:up:half)
        endfunction

        augroup fern-settings
          autocmd!
          autocmd FileType fern call s:fern_settings()
        augroup END
      ]])
    end,
  },
  { "lambdalisue/fern-renderer-nerdfont.vim", dependencies = { "lambdalisue/fern.vim" } },
  { "lambdalisue/nerdfont.vim" },
  { "lambdalisue/glyph-palette.vim" },
  { "lambdalisue/fern-git-status.vim", dependencies = { "lambdalisue/fern.vim" } },
  { "yuki-yano/fern-preview.vim", dependencies = { "lambdalisue/fern.vim" } },
  { "lambdalisue/fern-hijack.vim", dependencies = { "lambdalisue/fern.vim" } },
  { "lambdalisue/fern-bookmark.vim", dependencies = { "lambdalisue/fern.vim" } },
}

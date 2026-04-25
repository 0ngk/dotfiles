return {
  {
    "lambdalisue/fern.vim",
    lazy = false,
    dependencies = {
      "lambdalisue/glyph-palette.vim",
      "lambdalisue/nerdfont.vim",
      "lambdalisue/fern-renderer-nerdfont.vim",
      "lambdalisue/fern-git-status.vim",
      "yuki-yano/fern-preview.vim",
      "lambdalisue/fern-hijack.vim",
      "lambdalisue/fern-bookmark.vim",
    },
    init = function()
      local g = vim.g
      g["fern#renderer"] = "nerdfont"
      g["fern#default_hidden"] = true
    end,
    config = function()
      vim.cmd([[
        augroup my-glyph-palette
          autocmd! *
          autocmd FileType fern if exists('*glyph_palette#apply') | call glyph_palette#apply() | endif
          autocmd FileType nerdtree,startify if exists('*glyph_palette#apply') | call glyph_palette#apply() | endif
        augroup END

        function! s:fern_settings() abort
          nmap <silent> <buffer> p     <Plug>(fern-action-preview:toggle)
          nmap <silent> <buffer> <C-p> <Plug>(fern-action-preview:auto:toggle)
          nmap <silent> <buffer> <C-d> <Plug>(fern-action-preview:scroll:down:half)
          nmap <silent> <buffer> <C-u> <Plug>(fern-action-preview:scroll:up:half)
        endfunction

        augroup fern-settings
          autocmd!
          autocmd FileType fern if exists('*fern_git_status#init') | call fern_git_status#init() | endif
          autocmd FileType fern call s:fern_settings()
        augroup END
      ]])

      if vim.fn.exists("*fern_git_status#init") == 1 then
        vim.fn["fern_git_status#init"]()
      end
    end,
  },
}

return {
  {
    "uga-rosa/denippet.vim",
    event = "InsertEnter",
    dependencies = { "vim-denops/denops.vim" },
    config = function()
      local function load_snippets_dir(dir)
        if vim.fn.isdirectory(dir) ~= 1 then
          return
        end

        for name, type in vim.fs.dir(dir) do
          if type == "file" then
            vim.fn["denippet#load"](vim.fs.joinpath(dir, name))
          elseif type == "directory" then
            local subdir = vim.fs.joinpath(dir, name)
            for name2, type2 in vim.fs.dir(subdir) do
              if type2 == "file" then
                vim.fn["denippet#load"](vim.fs.joinpath(subdir, name2))
              end
            end
          end
        end
      end

      load_snippets_dir(vim.fn.stdpath("data") .. "/lazy/friendly-snippets/snippets")
      load_snippets_dir(vim.fn.stdpath("config") .. "/snippets")
    end,
  },
  { "rafamadriz/friendly-snippets" },
  { "Shougo/neosnippet-snippets" },
}

return {
  'christoomey/vim-tmux-navigator',
  'editorconfig/editorconfig-vim',
  'folke/zen-mode.nvim',
  'ggandor/leap.nvim',
  'micarmst/vim-spellsync',
  {
    'tpope/vim-surround',
    keys = { 'c', 'd', 'y' }
  },
  {
    'projekt0n/github-nvim-theme',
    priority = 1000,
    config = function()
      require('github-theme').setup({
        theme_style = 'light'
      })
      vim.cmd.colorscheme 'github_light'
    end,
  },
  {
    "vimwiki/vimwiki",
    config = function()
      vim.cmd("let g:vimwiki_list = [{'path': '~/dev/garden/', 'syntax': 'markdown', 'ext': '.md'}]")
      vim.cmd("let g:vimwiki_folding='expr'")
      vim.cmd("let g:vimwiki_global_ext = 0")
    end,
    branch = "dev"
  },
}

return function(use)
  use({ "christoomey/vim-tmux-navigator" })
  use({ "editorconfig/editorconfig-vim" })
  use({
    "folke/zen-mode.nvim",
    config = function()
      require("zen-mode").setup {
        plugins = {
          kitty = {
            enabled = true,
            font = "+4",
          }
        }
      }
    end

  })
  use({ "micarmst/vim-spellsync" })
  use({
    "tpope/vim-surround",
    keys = { "c", "d", "y" }
  })
  use({
    "projekt0n/github-nvim-theme",
    config = function()
      require("github-theme").setup({
        theme_style = "light"
      })
    end
  })
  use({
    "vimwiki/vimwiki",
    config = function()
      vim.cmd("let g:vimwiki_list = [{'path': '~/dev/garden/', 'syntax': 'markdown', 'ext': '.md'}]")
      vim.cmd("let g:vimwiki_folding='expr'")
    end,
    branch = "dev"
  })
end

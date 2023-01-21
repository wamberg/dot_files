return function(use)
  use({ "christoomey/vim-tmux-navigator" })
  use({ "editorconfig/editorconfig-vim" })
  use({ "folke/zen-mode.nvim" })
  use({ "ggandor/leap.nvim" })
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
end

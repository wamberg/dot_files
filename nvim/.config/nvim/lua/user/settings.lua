local opts = { noremap = true, silent = true }
local map = vim.api.nvim_set_keymap
local set = vim.opt

local config = {

  -- Set colorscheme
  colorscheme = "github_light",

  -- Add plugins
  plugins = {
    { "christoomey/vim-tmux-navigator" },
    { "editorconfig/editorconfig-vim" },
    { "micarmst/vim-spellsync" },
    {
      "projekt0n/github-nvim-theme",
      after = "lualine.nvim",
      config = function()
        require("github-theme").setup({
          theme_style = "light_default"
        })
      end,
    },
  },

  -- On/off virtual diagnostics text
  virtual_text = true,

  -- Disable default plugins
  enabled = {
    nvim_tree = false,
    lualine = true,
    lspsaga = true,
    gitsigns = true,
    colorizer = true,
    toggle_term = false,
    comment = true,
    symbols_outline = true,
    indent_blankline = true,
    dashboard = false,
    which_key = true,
    neoscroll = false,
    ts_rainbow = true,
    ts_autotag = true,
  },
}

-- Set options
set.relativenumber = true

-- Set key bindings
map('n', '<c-d>', '<c-e>', opts) -- move viewport down
map('n', '<c-u>', '<c-y>', opts) -- move viewport up
map('n', '<leader>ff', '<cmd>Telescope git_files<cr>', opts)
map('n', '<leader>fg', '<cmd>Telescope live_grep<cr>', opts)
map('n', '<leader>fh', '<cmd>Telescope grep_string search=^#\\  use_regex=true=<cr>', opts)
map('n', '<leader>fw', '<cmd>Telescope grep_string<cr>', opts)

-- Set autocommands
vim.cmd [[
  augroup packer_conf
    autocmd!
    autocmd bufwritepost plugins.lua source <afile> | PackerSync
  augroup end
]]

return config

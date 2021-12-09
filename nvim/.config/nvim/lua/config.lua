-----------------
-- Key Mappings
-----------------
local keymap = vim.api.nvim_set_keymap

keymap('n', '<c-d>', '<c-e>', { silent = true }) -- move viewport down
keymap('n', '<c-u>', '<c-y>', { silent = true }) -- move viewport up
keymap('n', '<leader>es', '<cmd>UltiSnipsEdit<cr>', {})
keymap('n', '<leader>fb', '<cmd>Telescope buffers<cr>', {})
keymap('n', '<leader>ff', '<cmd>Telescope git_files<cr>', {})
keymap('n', '<leader>fg', '<cmd>Telescope live_grep<cr>', {})
keymap('n', '<leader>fh', '<cmd>Telescope grep_string search=^#\\  use_regex=true=<cr>', {})
keymap('n', '<leader>fl', '<cmd>lua require("zettel").link_post()<cr>', {})
keymap('n', '<leader>fw', '<cmd>Telescope grep_string<cr>', {})

------------------
-- Plugin Config
------------------

--------------
-- Telescope
local actions = require('telescope.actions')
require('telescope').setup {
  defaults = {
    mappings = {
      i = {
        ["<C-v>"] = actions.select_vertical,
        ["<C-h>"] = actions.select_horizontal,
      }
    }
  }
}
-- To get fzf loaded and working with telescope, you need to call
-- load_extension, somewhere after setup function:
require('telescope').load_extension('fzf')

-----------
-- Lualine
require('lualine').setup {
  options = {
    theme = 'github',
  },
  sections = {
    lualine_c = {
      {
        'filename',
        file_status = true,
        path = 1
      }
    },
    lualine_x = {'encoding', 'filetype'},
  }
}

-----------
-- Zettel
require('zettel')

--------------------
-- nvim-treesitter
-- See available: https://github.com/nvim-treesitter/nvim-treesitter#supported-languages
require'nvim-treesitter.configs'.setup {
  ensure_installed = {
    "bash",
    "go",
    "javascript",
    "nix",
    "python",
    "toml",
    "tsx",
    "typescript",
    "yaml",
  },
  highlight = {
    enable = true,
  },
}

local parser_config = require "nvim-treesitter.parsers".get_parser_configs()
parser_config.python.used_by = "bzl"

--------------
-- UltiSnips
vim.g.UltiSnipsSnippetDirectories = { '~/.config/nvim/ultisnips' }

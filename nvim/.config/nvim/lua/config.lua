-----------------
-- Key Mappings
-----------------
local keymap = vim.api.nvim_set_keymap

keymap('n', '<c-u>', '<c-y>', { silent = true }) -- move viewport up
keymap('n', '<c-d>', '<c-e>', { silent = true }) -- move viewport down
keymap('n', '<leader>ff', "<cmd>Telescope git_files<cr>", {})
keymap('n', '<leader>fg', "<cmd>Telescope live_grep<cr>", {})
keymap('n', '<leader>fb', "<cmd>Telescope buffers<cr>", {})
keymap('n', '<leader>fw', "<cmd>Telescope grep_string<cr>", {})
keymap('n', '<leader>fh', "<cmd>Telescope grep_string search=^#\\  use_regex=true=<cr>", {})
keymap('i', '<leader>fl', "<cmd>lua require('zettel').link_post()<cr>", {})

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
        ["<C-x>"] = actions.select_vertical,
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
    lualine_x = {'encoding', 'filetype'},
  }
}

-----------
-- Zettel
require('zettel')

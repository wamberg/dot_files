-----------------
-- Key Mappings
-----------------
local keymap = vim.api.nvim_set_keymap

keymap('n', '<c-u>', '<c-y>', { silent = true }) -- move viewport up
keymap('n', '<c-d>', '<c-e>', { silent = true }) -- move viewport down
keymap('n', '<leader>ff', '<cmd>Telescope git_files<cr>', {})
keymap('n', '<leader>fg', '<cmd>Telescope live_grep<cr>', {})
keymap('n', '<leader>fb', '<cmd>Telescope buffers<cr>', {})
keymap('n', '<leader>fw', '<cmd>Telescope grep_string<cr>', {})
keymap('n', '<leader>fh', '<cmd>Telescope grep_string search=^#\\  use_regex=true=<cr>', {})
keymap('i', '<leader>fl', '<cmd>lua require("zettel").link_post()<cr>', {})

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
    lualine_b = {
      'branch',
      {'diagnostics', sources={ 'nvim_lsp' }}
    },
    lualine_x = {'encoding', 'filetype'},
  }
}

-----------
-- Zettel
require('zettel')

--------------------
-- nvim-treesitter
require'nvim-treesitter.configs'.setup {
ensure_installed = {
      "go",
      "javascript",
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

---------------------
-- neovim-lspconfig
local nvim_lsp = require('lspconfig')

-- Use an on_attach function to only map the following keys
-- after the language server attaches to the current buffer
local on_attach = function(client, bufnr)
  local function buf_set_keymap(...) vim.api.nvim_buf_set_keymap(bufnr, ...) end
  local function buf_set_option(...) vim.api.nvim_buf_set_option(bufnr, ...) end

  -- Enable completion triggered by <c-x><c-o>
  buf_set_option('omnifunc', 'v:lua.vim.lsp.omnifunc')

  -- Mappings.
  local opts = { noremap=true, silent=true }

  -- See `:help vim.lsp.*` for documentation on any of the below functions
  buf_set_keymap('n', 'gD', '<cmd>lua vim.lsp.buf.declaration()<CR>', opts)
  buf_set_keymap('n', 'gd', '<cmd>lua vim.lsp.buf.definition()<CR>', opts)
  buf_set_keymap('n', 'K', '<cmd>lua vim.lsp.buf.hover()<CR>', opts)
  buf_set_keymap('n', 'gi', '<cmd>lua vim.lsp.buf.implementation()<CR>', opts)
  buf_set_keymap('n', '<space>D', '<cmd>lua vim.lsp.buf.type_definition()<CR>', opts)
  buf_set_keymap('n', '<space>rn', '<cmd>lua vim.lsp.buf.rename()<CR>', opts)
  buf_set_keymap('n', 'gr', '<cmd>lua vim.lsp.buf.references()<CR>', opts)
  buf_set_keymap('n', '<space>e', '<cmd>lua vim.lsp.diagnostic.show_line_diagnostics()<CR>', opts)
  buf_set_keymap('n', '[d', '<cmd>lua vim.lsp.diagnostic.goto_prev()<CR>', opts)
  buf_set_keymap('n', ']d', '<cmd>lua vim.lsp.diagnostic.goto_next()<CR>', opts)
  buf_set_keymap('n', '<space>f', '<cmd>lua vim.lsp.buf.formatting()<CR>', opts)

end

-- Use a loop to conveniently call 'setup' on multiple servers and
-- map buffer local keybindings when the language server attaches
local servers = { 'gopls' }
for _, lsp in ipairs(servers) do
  nvim_lsp[lsp].setup {
    on_attach = on_attach,
    flags = {
      debounce_text_changes = 150,
    }
  }
end

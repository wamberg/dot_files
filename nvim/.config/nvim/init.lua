GARDEN=vim.fn.expandcmd('~/dev/garden')
require("kickstart.init")

-- Line numbers
vim.opt.number = false
require('leap').opts.safe_labels = {}
require('leap').add_default_mappings()

-- Folds
vim.opt.foldlevel = 99
vim.opt.foldmethod = "manual"

-- Display
vim.opt.scrolloff = 2
vim.opt.splitbelow = true
vim.opt.splitright = true
vim.opt.wrap = true

-- Window keymaps
vim.keymap.set('n', '<leader>c', ":bprevious<bar>bdelete #<CR>", { desc = '[C]lear Buffer' })
vim.keymap.set('n', '<leader>h', ":nohlsearch<CR>", { desc = 'Clear [H]ighlight' })

-- Code Keymaps
vim.keymap.set('n', '<leader>F', ":Format<CR>", { desc = '[F]ormat' })
vim.keymap.set('n', '<leader>fk', require('telescope.builtin').keymaps, { desc = '[F]ind [K]eymaps' })

-- Zettel keymaps
vim.keymap.set('i', '<C-l>', require('zettel').link_post, { desc = '[C]reate Link' })
vim.keymap.set('n', '<leader>fh', '<cmd>Telescope grep_string use_regex=true search=^#\\ <cr>',
  { desc = '[F]ind [H]eader' })
vim.keymap.set('n', '<leader>nn', require('zettel').new_note, { desc = '[N]ew [N]ote' })

-- Toggle Zen mode
local zentoggle = function()
  require('zen-mode').toggle({
    window = {
      width = 86
    },
    plugins = {
      gitsigns = {
        enabled = true
      },
      kitty = {
        enabled = true,
        font = "+4",
      }
    }
  })
end
vim.keymap.set('n', '<leader>z', zentoggle, { desc = '[Z]en Mode' })
-- Snippets
require("luasnip.loaders.from_snipmate").lazy_load({paths = './snippets'})
vim.keymap.set('n', '<leader>es', require("luasnip.loaders").edit_snippet_files, { desc = '[E]dit [S]nippets' })

----------------
-- Autocommands
----------------

-- Format Markdown
vim.api.nvim_create_autocmd("BufWritePre", {
  pattern = "*.md",
  callback = function()
    local command = "npm run format-file " .. vim.fn.expand("%")
    local function reload()
      vim.cmd('edit')
    end

    vim.fn.jobstart(command, { on_exit = reload })
  end,
  group = vim.api.nvim_create_augroup("markdown_autoformat", { clear = true }),
})

-- Display Markdown
vim.api.nvim_create_autocmd("FileType", {
  pattern = "vimwiki,markdown",
  callback = function()
    vim.cmd [[highlight VimwikiHeader1 guifg=blue gui=bold]]
    vim.cmd [[highlight VimwikiHeader2 guifg=darkgreen gui=bold]]
    vim.cmd [[highlight VimwikiHeader3 guifg=darkorange3 gui=bold]]
    vim.cmd [[highlight VimwikiHeader4 guifg=magenta3 gui=bold]]
    vim.cmd [[highlight VimwikiHeader5 guifg=magenta gui=bold]]
    vim.api.nvim_win_set_option(0, "spell", true)
    vim.opt.linebreak = true
  end,
  group = vim.api.nvim_create_augroup("markdown_display", { clear = true }),
})

-- Format Golang
vim.api.nvim_create_autocmd("BufWritePre", {
  pattern = "*.go",
  callback = function()
    local command = "go fmt " .. vim.fn.expand("%")
    local function reload()
      vim.cmd('edit')
    end

    vim.fn.jobstart(command, { on_exit = reload })
  end,
  group = vim.api.nvim_create_augroup("golang_autoformat", { clear = true }),
})

----------------
-- LSP Config
----------------
-- local util = require('lspconfig/util')
--
-- local path = util.path
--
-- local function get_python_path(workspace)
--   -- Use activated virtualenv.
--   if vim.env.VIRTUAL_ENV then
--     return path.join(vim.env.VIRTUAL_ENV, 'bin', 'python')
--   end
--
--   -- Find and use virtualenv via poetry in workspace directory.
--   local match = vim.fn.glob(path.join(workspace, '.venv'))
--   if match ~= '' then
--     return path.join('.venv', 'bin', 'python')
--   end
--
--   -- Fallback to system Python.
--   return vim.fn.exepath('python3') or vim.fn.exepath('python') or 'python'
-- end
--
-- require'lspconfig'.pyright.setup {
--     on_init = function(client)
--         client.config.settings.python.pythonPath = get_python_path(client.config.root_dir)
--     end
-- }
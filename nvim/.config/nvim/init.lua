require("kickstart.init")

-- line numbers
vim.opt.cursorline = true
vim.opt.cursorlineopt = "number"
vim.opt.relativenumber = true

-- folds
vim.opt.foldlevel = 99
vim.opt.foldmethod = "manual"

-- display
vim.opt.scrolloff = 2
vim.opt.splitbelow = true
vim.opt.splitright = true
vim.opt.wrap = true

-- window keymaps
vim.keymap.set('n', '<leader>c', ":bprevious<bar>bdelete #<CR>", { desc = '[C]lear Buffer' })
vim.keymap.set('n', '<leader>h', ":nohlsearch<CR>", { desc = 'Clear [H]ighlight' })

-- code keymaps
vim.keymap.set('n', '<leader>F', ":Format<CR>", { desc = '[F]ormat' })

-- zettel keymaps
vim.keymap.set('i', '<C-l>', require('zettel').link_post, { desc = '[C]reate Link' })
vim.keymap.set('n', '<leader>fh', '<cmd>Telescope grep_string use_regex=true search=^#\\ <cr>',
  { desc = '[F]ind [H]eader' })
vim.keymap.set('n', '<leader>nn', require('zettel').new_note, { desc = '[N]ew [N]ote' })

-- Toggle Zen mode
vim.keymap.set('n', '<leader>z', require('zen-mode').toggle, { desc = '[Z]en Mode' })

-- vimwiki custom highlighting
vim.api.nvim_create_autocmd("FileType", {
  pattern = "vimwiki",
  callback = function()
    vim.cmd [[highlight VimwikiHeader1 guifg=blue gui=bold]]
    vim.cmd [[highlight VimwikiHeader2 guifg=darkgreen gui=bold]]
    vim.cmd [[highlight VimwikiHeader3 guifg=darkorange3 gui=bold]]
    vim.cmd [[highlight VimwikiHeader4 guifg=magenta3 gui=bold]]
    vim.cmd [[highlight VimwikiHeader5 guifg=magenta gui=bold]]
  end,
  group = vim.api.nvim_create_augroup("vimwiki_highlight", { clear = true }),
})

-------------
-- Snippets
-------------
require("luasnip.loaders.from_snipmate").lazy_load({paths = './snippets'})
vim.keymap.set('n', '<leader>es', require("luasnip.loaders").edit_snippet_files, { desc = '[E]dit [S]nippets' })

-------------
-- Formatters
-------------

-- markdown
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

-- golang
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

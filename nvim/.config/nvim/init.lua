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

-- zettel keymaps
vim.keymap.set('i', '<C-;>', require('zettel').link_post, { desc = '[C]reate Link' })   -- TODO: Here not working
vim.keymap.set('n', '<leader>nn', require('zettel').new_note, { desc = '[N]ew [N]ote' })

-- Toggle Zen mode
vim.keymap.set('n', '<leader>z', require('zen-mode').toggle, { desc = '[Z]en Mode' })

-- vimwiki specific highlighting
vim.api.nvim_create_autocmd("FileType", {
  pattern = "vimwiki",
  callback = function()
    vim.cmd [[highlight VimwikiHeader1 guifg=blue gui=bold]]
    vim.cmd [[highlight VimwikiHeader2 guifg=darkgreen gui=bold]]
    vim.cmd [[highlight VimwikiHeader3 guifg=darkorange3 gui=bold]]
    vim.cmd [[highlight VimwikiHeader4 guifg=magenta3 gui=bold]]
    vim.cmd [[highlight VimwikiHeader5 guifg=magenta gui=bold]]
  end,
})

-----------------
-- Customization
-----------------
lvim.colorscheme = "github_light"
lvim.format_on_save = {
  ---@usage pattern string pattern used for the autocommand (Default: '*')
  pattern = "*",
  ---@usage timeout number timeout in ms for the format request (Default: 1000)
  timeout = 2000,
  ---@usage filter func to select client
  filter = require("lvim.lsp.utils").format_filter,
}
lvim.log.level = "warn"
lvim.lsp.diagnostics.virtual_text = false
vim.opt.clipboard = "" -- disable nvim + clipboard
vim.opt.cursorline = true
vim.opt.cursorlineopt = "number"
vim.opt.foldlevel = 99
vim.opt.foldmethod = "manual"
vim.opt.mouse = "" -- disable mouse
vim.opt.relativenumber = true
vim.opt.scrolloff = 2
vim.opt.wrap = true

----------------------
-- Additional Plugins
----------------------
lvim.plugins = {
  { "christoomey/vim-tmux-navigator" },
  { "editorconfig/editorconfig-vim" },
  {
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

  },
  { "micarmst/vim-spellsync" },
  {
    "tpope/vim-surround",
    keys = { "c", "d", "y" }
  },
  {
    "projekt0n/github-nvim-theme",
    config = function()
      require("github-theme").setup({
        theme_style = "light"
      })
    end
  },
  {
    "vimwiki/vimwiki",
    config = function()
      vim.cmd("let g:vimwiki_list = [{'path': '~/dev/garden/', 'syntax': 'markdown', 'ext': '.md'}]")
      vim.cmd("let g:vimwiki_folding='expr'")
    end,
    branch = "dev"
  },
  { "waylonwalker/Telegraph.nvim" },
}

----------------
-- Key Mappings
----------------

-- [view all the defaults by pressing <leader>Lk]
lvim.leader = "space"

lvim.keys.normal_mode = {
  ["<C-u>"] = "<C-y>", -- move viewport up
  ["<C-d>"] = "<C-e>", -- move viewport down
  ["<Space>f"] = false, -- Remove default Telescope git_files. Handle with which_key later.
  ["<Space>w"] = false, -- Remove default save command
}

lvim.builtin.which_key.mappings["f"] = {
  name = "+Files",
  b = { "<cmd>Telescope buffers<cr>", "Buffers" },
  f = { "<cmd>Telescope git_files<cr>", "Files" },
  g = { "<cmd>Telescope live_grep<cr>", "Grep" },
  h = { "<cmd>Telescope grep_string use_regex=true search=^#\\ <cr>", "Headers" },
  l = { "<cmd>lua require('zettel').link_post()<cr>", "Link" },
  w = { "<cmd>Telescope grep_string<cr>", "Word under cursor" },
}
lvim.builtin.which_key.mappings["n"] = {
  name = "+Notes",
  g = { "<cmd>lua require'telegraph'.telegraph({cmd='glow --style light --pager {filepath}', how='tmux_popup'})<cr>", "Glow current" },
  n = { "<cmd>lua require('zettel').new_note()<cr>", "New note" },
  r = { "<cmd>lua require'telegraph'.telegraph({cmd='bash -c \"ls *.md | shuf -n 1 | xargs glow --style light --pager\"', how='tmux_popup'})<cr>", "Review Random" },
}
lvim.builtin.which_key.mappings["z"] = { "<cmd>ZenMode<cr>", "Zen Mode" }

--------------------------------
-- Builtin Plugin Configuration
--------------------------------
-- After changing plugin config exit and reopen LunarVim, Run :PackerInstall :PackerCompile
lvim.builtin.alpha.active = false
lvim.builtin.notify.active = true
lvim.builtin.terminal.active = true
lvim.builtin.nvimtree.setup.view.side = "left"
lvim.builtin.nvimtree.setup.renderer.icons.show.git = false

--------------
-- Treesitter
--------------

lvim.builtin.treesitter.ensure_installed = {
  "bash",
  "css",
  "hcl",
  "javascript",
  "json",
  "lua",
  "python",
  "rust",
  "tsx",
  "typescript",
  "yaml",
}

lvim.builtin.treesitter.ignore_install = { "haskell" }
lvim.builtin.treesitter.highlight.enabled = true

--------------
-- Formatters
--------------
local formatters = require "lvim.lsp.null-ls.formatters"
formatters.setup {
  { command = "black", filetypes = { "python" } },
  { command = "isort", filetypes = { "python" } },
  {
    command = "prettier",
    extra_args = { "--prose-wrap", "always" },
    filetypes = { "typescript", "typescriptreact", "vimwiki" },
  },
}

-----------
-- Linters
-----------
local linters = require "lvim.lsp.null-ls.linters"
linters.setup {
  { command = "flake8", filetypes = { "python" } },
}

-- Autocommands (https://neovim.io/doc/user/autocmd.html)
vim.api.nvim_create_autocmd("FileType", {
  pattern = "zsh",
  callback = function()
    -- let treesitter use bash highlight for zsh files as well
    require("nvim-treesitter.highlight").attach(0, "bash")
  end,
})

vim.api.nvim_create_autocmd("FileType", {
  pattern = "vimwiki",
  callback = function()
    require('cmp').setup.buffer({ completion = { autocomplete = false } })
    vim.cmd [[highlight VimwikiHeader1 guifg=blue gui=bold]]
    vim.cmd [[highlight VimwikiHeader2 guifg=darkgreen gui=bold]]
    vim.cmd [[highlight VimwikiHeader3 guifg=darkorange3 gui=bold]]
    vim.cmd [[highlight VimwikiHeader4 guifg=magenta3 gui=bold]]
    vim.cmd [[highlight VimwikiHeader5 guifg=magenta gui=bold]]
  end,
})

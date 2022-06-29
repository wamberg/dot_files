-- general
lvim.log.level = "warn"
lvim.format_on_save = true
lvim.colorscheme = "github_light"

-- keymappings [view all the defaults by pressing <leader>Lk]
lvim.leader = "space"

-- my keymapping

lvim.keys.normal_mode = {
  ["<C-u>"] = "<C-y>", -- move viewport up
  ["<C-d>"] = "<C-e>", -- move viewport down
  ["<Space>f"] = false, -- Remove default Telescope git_files. Handle with which_key later.
}

lvim.builtin.which_key.mappings["f"] = {
  name = "+Files",
  b = { "<cmd>Telescope buffers<cr>", "Buffers" },
  f = { "<cmd>Telescope git_files<cr>", "Files" },
  g = { "<cmd>Telescope live_grep<cr>", "Grep" },
  h = { "<cmd>Telescope grep_string use_regex=true search=^#\\ <cr>", "Headers" },
  l = { "<cmd>lua require('zettel').link_post()<cr>", "Link" },
  n = { "<cmd>lua require('zettel').new_note()<cr>", "New note" },
  w = { "<cmd>Telescope grep_string<cr>", "Word under cursor" },
}

lvim.builtin.which_key.mappings["t"] = {
  name = "+Trouble",
  r = { "<cmd>Trouble lsp_references<cr>", "References" },
  f = { "<cmd>Trouble lsp_definitions<cr>", "Definitions" },
  d = { "<cmd>Trouble document_diagnostics<cr>", "Diagnostics" },
  q = { "<cmd>Trouble quickfix<cr>", "QuickFix" },
  l = { "<cmd>Trouble loclist<cr>", "LocationList" },
  w = { "<cmd>Trouble workspace_diagnostics<cr>", "Wordspace Diagnostics" },
}
lvim.builtin.which_key.mappings["z"] = { "<cmd>ZenMode<CR>", "Zen Mode" }

-- After changing plugin config exit and reopen LunarVim, Run :PackerInstall :PackerCompile
lvim.builtin.alpha.active = false
lvim.builtin.alpha.mode = "dashboard"
lvim.builtin.notify.active = true
lvim.builtin.terminal.active = true
lvim.builtin.nvimtree.setup.view.side = "left"
lvim.builtin.nvimtree.setup.renderer.icons.show.git = false

lvim.builtin.treesitter.ensure_installed = {
  "bash",
  "javascript",
  "json",
  "lua",
  "python",
  "typescript",
  "tsx",
  "css",
  "yaml",
}

lvim.builtin.treesitter.ignore_install = { "haskell" }
lvim.builtin.treesitter.highlight.enabled = true

-- set a formatter, this will override the language server formatting capabilities (if it exists)
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

-- set additional linters
local linters = require "lvim.lsp.null-ls.linters"
linters.setup {
  { command = "flake8", filetypes = { "python" } },
}


-----------------
-- Customization
-----------------
lvim.lsp.diagnostics.virtual_text = false
vim.opt.clipboard = "" -- disable nvim + clipboard
vim.opt.cursorline = true
vim.opt.cursorlineopt = "number"
vim.opt.foldmethod = "expr"
vim.opt.mouse = "" -- disable mouse
vim.opt.relativenumber = true
vim.opt.wrap = true

----------------------
-- Additional Plugins
----------------------
lvim.plugins = {
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
  {"christoomey/vim-tmux-navigator"},
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
  {"editorconfig/editorconfig-vim"},
  {"micarmst/vim-spellsync"},
  {
    "folke/trouble.nvim",
    config = function()
    require("trouble").setup { }
  end
  },
}

-- Autocommands (https://neovim.io/doc/user/autocmd.html)
vim.api.nvim_create_autocmd("FileType", {
  pattern = "zsh",
  callback = function()
    -- let treesitter use bash highlight for zsh files as well
    require("nvim-treesitter.highlight").attach(0, "bash")
  end,
})

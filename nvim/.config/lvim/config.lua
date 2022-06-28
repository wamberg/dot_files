--[[
lvim is the global options object

Linters should be
filled in as strings with either
a global executable or a path to
an executable
]]

-- general
lvim.log.level = "warn"
lvim.format_on_save = true
lvim.colorscheme = "github_light"

-- keymappings [view all the defaults by pressing <leader>Lk]
lvim.leader = "space"

-- my keymapping

-- unmap a default keymapping
-- vim.keymap.del("n", "<C-Up>")
-- override a default keymapping
lvim.keys.normal_mode = {
  ["<C-u>"] = "<C-y>", -- move viewport up
  ["<C-d>"] = "<C-e>", -- move viewport down
  ["<Space>f"] = false, -- Remove default Telescope git_files. Handle with which_key later.
}

-- Use which-key to add extra bindings with the leader-key prefix
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

-- TODO: User Config for predefined plugins
-- After changing plugin config exit and reopen LunarVim, Run :PackerInstall :PackerCompile
lvim.builtin.alpha.active = false
lvim.builtin.alpha.mode = "dashboard"
lvim.builtin.notify.active = true
lvim.builtin.terminal.active = true
lvim.builtin.nvimtree.setup.view.side = "left"
lvim.builtin.nvimtree.setup.renderer.icons.show.git = false

-- if you don't want all the parsers change this to a table of the ones you want
lvim.builtin.treesitter.ensure_installed = {
  "bash",
  "javascript",
  "json",
  "lua",
  "python",
  "typescript",
  "tsx",
  "css",
  "rust",
  "yaml",
}

lvim.builtin.treesitter.ignore_install = { "haskell" }
lvim.builtin.treesitter.highlight.enabled = true

-- generic LSP settings

-- -- make sure server will always be installed even if the server is in skipped_servers list
lvim.lsp.installer.setup.ensure_installed = {
   "sumeko_lua",
   "jsonls",
}
-- -- change UI setting of `LspInstallInfo`
-- -- see <https://github.com/williamboman/nvim-lsp-installer#default-configuration>
-- lvim.lsp.installer.setup.ui.check_outdated_servers_on_open = false
-- lvim.lsp.installer.setup.ui.border = "rounded"
-- lvim.lsp.installer.setup.ui.keymaps = {
--     uninstall_server = "d",
--     toggle_server_expand = "o",
-- }

-- ---@usage disable automatic installation of servers
-- lvim.lsp.automatic_servers_installation = false

-- ---configure a server manually. !!Requires `:LvimCacheReset` to take effect!!
-- ---see the full default list `:lua print(vim.inspect(lvim.lsp.automatic_configuration.skipped_servers))`
-- vim.list_extend(lvim.lsp.automatic_configuration.skipped_servers, { "pyright" })
-- local opts = {} -- check the lspconfig documentation for a list of all possible options
-- require("lvim.lsp.manager").setup("pyright", opts)

-- ---remove a server from the skipped list, e.g. eslint, or emmet_ls. !!Requires `:LvimCacheReset` to take effect!!
-- ---`:LvimInfo` lists which server(s) are skipped for the current filetype
-- vim.tbl_map(function(server)
--   return server ~= "emmet_ls"
-- end, lvim.lsp.automatic_configuration.skipped_servers)

-- -- you can set a custom on_attach function that will be used for all the language servers
-- -- See <https://github.com/neovim/nvim-lspconfig#keybindings-and-completion>
-- lvim.lsp.on_attach_callback = function(client, bufnr)
--   local function buf_set_option(...)
--     vim.api.nvim_buf_set_option(bufnr, ...)
--   end
--   --Enable completion triggered by <c-x><c-o>
--   buf_set_option("omnifunc", "v:lua.vim.lsp.omnifunc")
-- end

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

-- -- set additional linters
-- local linters = require "lvim.lsp.null-ls.linters"
-- linters.setup {
--   { command = "flake8", filetypes = { "python" } },
--   {
--     -- each linter accepts a list of options identical to https://github.com/jose-elias-alvarez/null-ls.nvim/blob/main/doc/BUILTINS.md#Configuration
--     command = "shellcheck",
--     ---@usage arguments to pass to the formatter
--     -- these cannot contain whitespaces, options such as `--line-width 80` become either `{'--line-width', '80'}` or `{'--line-width=80'}`
--     extra_args = { "--severity", "warning" },
--   },
--   {
--     command = "codespell",
--     ---@usage specify which filetypes to enable. By default a providers will attach to all the filetypes it supports.
--     filetypes = { "javascript", "python" },
--   },
-- }


-----------------
-- Customization
-----------------
vim.opt.mouse = "" -- disable mouse
vim.opt.relativenumber = true
vim.opt.wrap = true

-- Additional Plugins
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

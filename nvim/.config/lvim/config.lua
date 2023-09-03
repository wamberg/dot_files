-- vim options
vim.opt.clipboard = ""
vim.opt.mouse = ""
vim.opt.relativenumber = true
vim.opt.shiftwidth = 2
vim.opt.tabstop = 2

-- general
lvim.log.level = "info"
lvim.format_on_save = {
  enabled = true,
  pattern = "*",
  timeout = 2000,
  filter = require("lvim.lsp.utils").format_filter,
}

-- telescope config
lvim.builtin.telescope.defaults.path_display = { "truncate" }
-- lvim.builtin.telescope.theme = "dropdown"

-- keymappings <https://www.lunarvim.org/docs/configuration/keybindings>
lvim.leader = "space"

local search_mappings = lvim.builtin.which_key.mappings["s"]
search_mappings["b"] = { "<cmd>Telescope buffers<cr>", "Buffers" }
search_mappings["s"] = { '<cmd>lua require("luasnip.loaders").edit_snippet_files()<cr>', "Snippets" }
search_mappings["w"] = { "<cmd>Telescope grep_string<cr>", "Word under cursor" }
lvim.builtin.which_key.mappings["s"] = search_mappings

lvim.builtin.which_key.mappings["z"] = { "<cmd>ZenMode<cr>", "Zen Mode" }

-- lvim.keys.normal_mode["<S-l>"] = ":BufferLineCycleNext<CR>"
-- lvim.keys.normal_mode["<S-h>"] = ":BufferLineCyclePrev<CR>"

-- -- Use which-key to add extra bindings with the leader-key prefix
-- lvim.builtin.which_key.mappings["W"] = { "<cmd>noautocmd w<cr>", "Save without formatting" }
-- lvim.builtin.which_key.mappings["P"] = { "<cmd>Telescope projects<CR>", "Projects" }

lvim.builtin.alpha.active = false
lvim.builtin.nvimtree.setup.renderer.icons.show.git = false
lvim.builtin.nvimtree.setup.view.side = "right"
lvim.builtin.project.active = false
lvim.builtin.terminal.active = false

-- Automatically install missing parsers when entering buffer
lvim.builtin.treesitter.auto_install = true

-- lvim.builtin.treesitter.ignore_install = { "haskell" }

-- -- always installed on startup, useful for parsers without a strict filetype
-- lvim.builtin.treesitter.ensure_installed = { "comment", "markdown_inline", "regex" }

-- -- generic LSP settings <https://www.lunarvim.org/docs/languages#lsp-support>

-- --- disable automatic installation of servers
-- lvim.lsp.installer.setup.automatic_installation = false

-- ---configure a server manually. IMPORTANT: Requires `:LvimCacheReset` to take effect
-- ---see the full default list `:lua =lvim.lsp.automatic_configuration.skipped_servers`
-- vim.list_extend(lvim.lsp.automatic_configuration.skipped_servers, { "pyright" })
-- local opts = {} -- check the lspconfig documentation for a list of all possible options
-- require("lvim.lsp.manager").setup("pyright", opts)

-- Configure emmet_ls
-- local emmet_options = {
--   filetypes = {
--     "html",
--     "javascript",
--     "javascriptreact",
--     "jinja",
--     "typescript",
--   },
--   root_dir = function()
--     return vim.loop.cwd()
--   end,
-- }
-- require("lvim.lsp.manager").setup("emmet_ls", emmet_options)

-- Configure tailwindcss language server
local tailwind_options = {
  filetypes = {
    "html",
    "htmldjango",
    "jinja",
  },
  root_dir = function()
    return vim.loop.cwd()
  end,
}
require("lvim.lsp.manager").setup("tailwindcss", tailwind_options)

-- ---remove a server from the skipped list, e.g. eslint, or emmet_ls. IMPORTANT: Requires `:LvimCacheReset` to take effect
-- ---`:LvimInfo` lists which server(s) are skipped for the current filetype
-- lvim.lsp.automatic_configuration.skipped_servers = vim.tbl_filter(function(server)
--   return server ~= "emmet_ls"
-- end, lvim.lsp.automatic_configuration.skipped_servers)
vim.list_extend(lvim.lsp.automatic_configuration.skipped_servers, { "pylyzer" })

-- -- you can set a custom on_attach function that will be used for all the language servers
-- -- See <https://github.com/neovim/nvim-lspconfig#keybindings-and-completion>
-- lvim.lsp.on_attach_callback = function(client, bufnr)
--   local function buf_set_option(...)
--     vim.api.nvim_buf_set_option(bufnr, ...)
--   end
--   --Enable completion triggered by <c-x><c-o>
--   buf_set_option("omnifunc", "v:lua.vim.lsp.omnifunc")
-- end

-- linters and formatters <https://www.lunarvim.org/docs/languages#lintingformatting>
local formatters = require("lvim.lsp.null-ls.formatters")
formatters.setup({
  { command = "stylua" },
  {
    command = "prettier",
    extra_args = { "--print-width", "100" },
    filetypes = { "typescript", "typescriptreact" },
  },
})
local linters = require("lvim.lsp.null-ls.linters")
linters.setup({
  { command = "ruff", filetypes = { "python" } },
  {
    command = "shellcheck",
    args = { "--severity", "warning" },
  },
})

-- Customization
lvim.colorscheme = "github_dark_high_contrast"
lvim.transparent_window = true
require("luasnip").filetype_extend("svelte", { "javascript" })

-- -- Additional Plugins <https://www.lunarvim.org/docs/plugins#user-plugins>
lvim.plugins = {
  { "christoomey/vim-tmux-navigator" },
  { "editorconfig/editorconfig-vim" },
  {
    "folke/zen-mode.nvim",
    config = function()
      require("zen-mode").setup({
        plugins = {
          kitty = {
            enabled = true,
            font = "+4",
          },
        },
      })
    end,
  },
  { "Glench/Vim-Jinja2-Syntax" },
  { "micarmst/vim-spellsync" },
  {
    "tpope/vim-surround",
    keys = { "c", "d", "y" },
  },
  { "projekt0n/github-nvim-theme" },
}

-- Autocommands (`:help autocmd`) <https://neovim.io/doc/user/autocmd.html>
vim.api.nvim_create_autocmd("FileType", {
  pattern = "zsh",
  callback = function()
    -- let treesitter use bash highlight for zsh files as well
    require("nvim-treesitter.highlight").attach(0, "bash")
  end,
})

vim.g.mapleader = " " -- Make sure to set `mapleader` before lazy so your mappings are correct

-- Bootstrap Lazy.nvim
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable", -- latest stable release
    lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

-- Setup Lazy plugins
require("lazy").setup({
  "christoomey/vim-tmux-navigator",
  "editorconfig/editorconfig-vim",
  "folke/zen-mode.nvim",
  {
    "L3MON4D3/LuaSnip",
    version = "2.*",
  },
  "lewis6991/gitsigns.nvim",
  "micarmst/vim-spellsync",
  "Mofiqul/dracula.nvim",
  {
    "nvim-telescope/telescope.nvim",
    tag = "0.1.2",
    dependencies = { "nvim-lua/plenary.nvim" },
  },
  {
    "nvim-treesitter/nvim-treesitter",
    build = ":TSUpdate",
    config = function()
      local configs = require("nvim-treesitter.configs")
      configs.setup({
        ensure_installed = {
          "bash",
          "css",
          "dockerfile",
          "git_config",
          "git_rebase",
          "gitcommit",
          "go",
          "html",
          "htmldjango",
          "json",
          "lua",
          "make",
          "markdown",
          "python",
          "sql",
          "toml",
          "typescript",
        },
        highlight = {
          enable = true,
        },
      })
    end,
  },
  "RRethy/vim-illuminate",
  {
    "tpope/vim-surround",
    keys = { "c", "d", "y" },
  },
  {
    "windwp/nvim-autopairs",
    event = "InsertEnter",
    opts = {},
  },
})

-- Line numbers
vim.opt.number = true
vim.wo.relativenumber = true
vim.wo.cursorline = true
vim.wo.cursorlineopt = "number"

-- Folds
vim.opt.foldlevel = 99
vim.opt.foldmethod = "manual"

-- Display
vim.opt.scrolloff = 2
vim.opt.splitbelow = true
vim.opt.splitright = true
vim.opt.wrap = true

-- Window keymaps
vim.keymap.set("n", "<leader>c", ":bprevious<bar>bdelete #<CR>", { desc = "[C]lear Buffer" })
vim.keymap.set("n", "<leader>h", ":nohlsearch<CR>", { desc = "Clear [H]ighlight" })

-- Code Keymaps
vim.keymap.set("n", "<leader>F", ":Format<CR>", { desc = "[F]ormat" })
vim.keymap.set("n", "<leader>fk", require("telescope.builtin").keymaps, { desc = "[F]ind [K]eymaps" })

-- Telescope Keymaps
local builtin = require("telescope.builtin")
vim.keymap.set("n", "<leader>fb", builtin.buffers, {}, default_opts)
vim.keymap.set("n", "<leader>fc", builtin.grep_string, default_opts)
vim.keymap.set("n", "<leader>ff", builtin.find_files, default_opts)
vim.keymap.set("n", "<leader>fg", builtin.live_grep, default_opts)

-- Toggle Zen mode
local zentoggle = function()
  require("zen-mode").toggle({
    window = {
      width = 86,
    },
    plugins = {
      gitsigns = {
        enabled = true,
      },
      kitty = {
        enabled = true,
        font = "+4",
      },
    },
  })
end
vim.keymap.set("n", "<leader>z", zentoggle, { desc = "[Z]en Mode" })
-- Snippets
require("luasnip.loaders.from_snipmate").lazy_load({ paths = "./snippets" })
vim.keymap.set("n", "<leader>es", require("luasnip.loaders").edit_snippet_files, { desc = "[E]dit [S]nippets" })

-- gitsigns setup
require("gitsigns").setup({
  on_attach = function(bufnr)
    local gs = package.loaded.gitsigns

    local function map(mode, l, r, opts)
      opts = opts or {}
      opts.buffer = bufnr
      vim.keymap.set(mode, l, r, opts)
    end

    -- Navigation
    map("n", "]c", function()
      if vim.wo.diff then
        return "]c"
      end
      vim.schedule(function()
        gs.next_hunk()
      end)
      return "<Ignore>"
    end, { expr = true })

    map("n", "[c", function()
      if vim.wo.diff then
        return "[c"
      end
      vim.schedule(function()
        gs.prev_hunk()
      end)
      return "<Ignore>"
    end, { expr = true })

    -- Actions
    map("n", "<leader>hs", gs.stage_hunk)
    map("n", "<leader>hr", gs.reset_hunk)
    map("v", "<leader>hs", function()
      gs.stage_hunk({ vim.fn.line("."), vim.fn.line("v") })
    end)
    map("v", "<leader>hr", function()
      gs.reset_hunk({ vim.fn.line("."), vim.fn.line("v") })
    end)
    map("n", "<leader>hS", gs.stage_buffer)
    map("n", "<leader>hu", gs.undo_stage_hunk)
    map("n", "<leader>hR", gs.reset_buffer)
    map("n", "<leader>hp", gs.preview_hunk)
    map("n", "<leader>hb", function()
      gs.blame_line({ full = true })
    end)
    map("n", "<leader>tb", gs.toggle_current_line_blame)
    map("n", "<leader>hd", gs.diffthis)
    map("n", "<leader>hD", function()
      gs.diffthis("~")
    end)
    map("n", "<leader>td", gs.toggle_deleted)

    -- Text object
    map({ "o", "x" }, "ih", ":<C-U>Gitsigns select_hunk<CR>")
  end,
})

-- Telescope setup
require("telescope").setup({
  pickers = {
    find_files = {
      hidden = true,
    },
    grep_string = {
      additional_args = function(opts)
        return { "--hidden" }
      end,
    },
    live_grep = {
      additional_args = function(opts)
        return { "--hidden" }
      end,
    },
  },
})

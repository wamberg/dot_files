---@diagnostic disable-next-line: undefined-global
local vim = vim

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
  {
    "akinsho/bufferline.nvim",
    version = "*",
    dependencies = "nvim-tree/nvim-web-devicons",
  },
  "christoomey/vim-tmux-navigator",
  "editorconfig/editorconfig-vim",
  "folke/zen-mode.nvim",
  "ggandor/leap.nvim",
  "lewis6991/gitsigns.nvim",
  "micarmst/vim-spellsync",
  "tinted-theming/tinted-vim",
  {
    "nvim-telescope/telescope.nvim",
    tag = "v0.2.0",
    dependencies = { "nvim-lua/plenary.nvim" },
  },
  {
    "nvim-treesitter/nvim-treesitter",
    build = ":TSUpdate",
    opts = {
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
        "markdown_inline",
        "python",
        "sql",
        "toml",
        "typescript",
        "vimdoc",
      },
      highlight = {
        enable = true,
      },
    },
  },
  "ojroques/nvim-bufdel",
  "RRethy/vim-illuminate",
  { "tpope/vim-surround" },
  {
    "windwp/nvim-autopairs",
    event = "InsertEnter",
    opts = {},
  },

  { -- LSP Configuration & Plugins
    -- Note: We don't need nvim-lspconfig in Neovim 0.11+
    -- Using built-in vim.lsp.config and vim.lsp.enable() instead
    name = "lsp-setup",
    dir = vim.fn.stdpath("config"),
    dependencies = {
      -- Useful status updates for LSP.
      -- NOTE: `opts = {}` is the same as calling `require('fidget').setup({})`
      { "j-hui/fidget.nvim", opts = {} },
    },
    config = function()
      -- Brief aside: **What is LSP?**
      --
      -- LSP is an initialism you've probably heard, but might not understand what it is.
      --
      -- LSP stands for Language Server Protocol. It's a protocol that helps editors
      -- and language tooling communicate in a standardized fashion.
      --
      -- In general, you have a "server" which is some tool built to understand a particular
      -- language (such as `gopls`, `lua_ls`, `rust_analyzer`, etc.). These Language Servers
      -- (sometimes called LSP servers, but that's kind of like ATM Machine) are standalone
      -- processes that communicate with some "client" - in this case, Neovim!
      --
      -- LSP provides Neovim with features like:
      --  - Go to definition
      --  - Find references
      --  - Autocompletion
      --  - Symbol Search
      --  - and more!
      --
      -- Thus, Language Servers are external tools that must be installed separately from
      -- Neovim. This is where `mason` and related plugins come into play.
      --
      -- If you're wondering about lsp vs treesitter, you can check out the wonderfully
      -- and elegantly composed help section, `:help lsp-vs-treesitter`

      --  This function gets run when an LSP attaches to a particular buffer.
      --    That is to say, every time a new file is opened that is associated with
      --    an lsp (for example, opening `main.rs` is associated with `rust_analyzer`) this
      --    function will be executed to configure the current buffer
      vim.api.nvim_create_autocmd("LspAttach", {
        group = vim.api.nvim_create_augroup("kickstart-lsp-attach", { clear = true }),
        callback = function(event)
          -- NOTE: Remember that Lua is a real programming language, and as such it is possible
          -- to define small helper and utility functions so you don't have to repeat yourself.
          --
          -- In this case, we create a function that lets us more easily define mappings specific
          -- for LSP related items. It sets the mode, buffer and description for us each time.
          local map = function(keys, func, desc)
            vim.keymap.set("n", keys, func, { buffer = event.buf, desc = "LSP: " .. desc })
          end

          -- Jump to the definition of the word under your cursor.
          --  This is where a variable was first declared, or where a function is defined, etc.
          --  To jump back, press <C-t>.
          map("gd", require("telescope.builtin").lsp_definitions, "[G]oto [D]efinition")

          -- Find references for the word under your cursor.
          map("gr", require("telescope.builtin").lsp_references, "[G]oto [R]eferences")

          -- Jump to the implementation of the word under your cursor.
          --  Useful when your language has ways of declaring types without an actual implementation.
          map("gI", require("telescope.builtin").lsp_implementations, "[G]oto [I]mplementation")

          -- Jump to the type of the word under your cursor.
          --  Useful when you're not sure what type a variable is and you want to see
          --  the definition of its *type*, not where it was *defined*.
          map("<leader>D", require("telescope.builtin").lsp_type_definitions, "Type [D]efinition")

          -- Fuzzy find all the symbols in your current document.
          --  Symbols are things like variables, functions, types, etc.
          map("<leader>fs", require("telescope.builtin").lsp_document_symbols, "[F]ind [S]ymbols")

          -- Fuzzy find all the symbols in your current workspace.
          --  Similar to document symbols, except searches over your entire project.
          map("<leader>ws", require("telescope.builtin").lsp_dynamic_workspace_symbols, "[W]orkspace [S]ymbols")

          -- Rename the variable under your cursor.
          --  Most Language Servers support renaming across files, etc.
          map("<leader>rn", vim.lsp.buf.rename, "[R]e[n]ame")

          -- Execute a code action, usually your cursor needs to be on top of an error
          -- or a suggestion from your LSP for this to activate.
          map("<leader>oa", vim.lsp.buf.code_action, "C[o]de [A]ction")

          -- Opens a popup that displays documentation about the word under your cursor
          --  See `:help K` for why this keymap.
          map("K", vim.lsp.buf.hover, "Hover Documentation")

          -- WARN: This is not Goto Definition, this is Goto Declaration.
          --  For example, in C this would take you to the header.
          map("gD", vim.lsp.buf.declaration, "[G]oto [D]eclaration")

          -- The following two autocommands are used to highlight references of the
          -- word under your cursor when your cursor rests there for a little while.
          --    See `:help CursorHold` for information about when this is executed
          --
          -- When you move your cursor, the highlights will be cleared (the second autocommand).
          local client = vim.lsp.get_client_by_id(event.data.client_id)
          if client and client.server_capabilities.documentHighlightProvider then
            vim.api.nvim_create_autocmd({ "CursorHold", "CursorHoldI" }, {
              buffer = event.buf,
              callback = vim.lsp.buf.document_highlight,
            })

            vim.api.nvim_create_autocmd({ "CursorMoved", "CursorMovedI" }, {
              buffer = event.buf,
              callback = vim.lsp.buf.clear_references,
            })
          end
        end,
      })

      -- LSP servers and clients are able to communicate to each other what features they support.
      --  By default, Neovim doesn't support everything that is in the LSP specification.
      --  When you add nvim-cmp, luasnip, etc. Neovim now has *more* capabilities.
      --  So, we create new capabilities with nvim cmp, and then broadcast that to the servers.
      local capabilities = vim.lsp.protocol.make_client_capabilities()
      capabilities = vim.tbl_deep_extend("force", capabilities, require("cmp_nvim_lsp").default_capabilities())

      -- Enable the following language servers
      --  Feel free to add/remove any LSPs that you want here. They will automatically be installed.
      --
      --  Add any additional override configuration in the following tables. Available keys are:
      --  - cmd (table): Override the default command used to start the server
      --  - filetypes (table): Override the default list of associated filetypes for the server
      --  - capabilities (table): Override fields in capabilities. Can be used to disable certain LSP features.
      --  - settings (table): Override the default settings passed when initializing the server.
      --        For example, to see the options for `lua_ls`, you could go to: https://luals.github.io/wiki/settings/
      local servers = {
        htmx = {
          filetypes = { "html", "htmldjango" },
        },
        ty = {
          filetypes = { "python" },
        },
        ts_ls = {
          filetypes = { "javascript", "javascriptreact", "typescript", "typescriptreact" },
        },
        lua_ls = {
          filetypes = { "lua" },
          settings = {
            Lua = {
              runtime = {
                version = "LuaJIT",
              },
              completion = {
                callSnippet = "Replace",
              },
              diagnostics = {
                globals = { "vim" }, -- Recognize 'vim' global
              },
              workspace = {
                library = {
                  vim.env.VIMRUNTIME,
                  "${3rd}/luv/library",
                },
                checkThirdParty = false,
              },
              telemetry = {
                enable = false,
              },
            },
          },
        },
      }

      -- NixOS: LSP servers are installed via Nix, not Mason
      -- Mason is disabled to avoid dynamically-linked binary issues on NixOS
      -- See: https://nix.dev/permalink/stub-ld

      -- Map server names to their actual binary commands
      local server_commands = {
        lua_ls = { "lua-language-server" },
        ty = { "ty", "server" },
        ts_ls = { "typescript-language-server", "--stdio" },
        htmx = { "htmx-lsp", "--level", "DEBUG" },
      }

      -- Configure each LSP server using vim.lsp.config (Neovim 0.11+)
      for server_name, server_config in pairs(servers) do
        vim.lsp.config[server_name] = vim.tbl_deep_extend("force", {
          cmd = server_commands[server_name],
          root_markers = { ".git", "pyproject.toml", "package.json" },
          capabilities = capabilities,
        }, server_config or {})

        -- Enable the LSP server
        vim.lsp.enable(server_name)
      end
    end,
  },

  { -- Autoformat
    "stevearc/conform.nvim",
    opts = {
      notify_on_error = false,
      format_on_save = function(bufnr)
        -- Disable "format_on_save lsp_fallback" for languages that don't
        -- have a well standardized coding style. You can add additional
        -- languages here or re-enable it for the disabled ones.
        local disable_filetypes = { c = true, cpp = true, html = true }
        return {
          timeout_ms = 500,
          lsp_fallback = not disable_filetypes[vim.bo[bufnr].filetype],
        }
      end,
      formatters_by_ft = {
        lua = { "stylua" },
        -- Conform can also run multiple formatters sequentially
        -- python = { "isort", "ruff_format" },
        --
        -- You can use a sub-list to tell conform to run *until* a formatter
        -- is found.
        -- javascript = { { "prettierd", "prettier" } },
      },
    },
  },

  { -- Autocompletion
    "hrsh7th/nvim-cmp",
    event = "InsertEnter",
    dependencies = {
      -- Snippet Engine & its associated nvim-cmp source
      {
        "L3MON4D3/LuaSnip",
        build = (function()
          -- Build Step is needed for regex support in snippets.
          -- This step is not supported in many windows environments.
          -- Remove the below condition to re-enable on windows.
          if vim.fn.has("win32") == 1 or vim.fn.executable("make") == 0 then
            return
          end
          return "make install_jsregexp"
        end)(),
        dependencies = {
          -- `friendly-snippets` contains a variety of premade snippets.
          --    See the README about individual language/framework/plugin snippets:
          --    https://github.com/rafamadriz/friendly-snippets
          -- {
          --   'rafamadriz/friendly-snippets',
          --   config = function()
          --     require('luasnip.loaders.from_vscode').lazy_load()
          --   end,
          -- },
        },
      },
      "saadparwaiz1/cmp_luasnip",

      -- Adds other completion capabilities.
      --  nvim-cmp does not ship with all sources by default. They are split
      --  into multiple repos for maintenance purposes.
      "hrsh7th/cmp-nvim-lsp",
      "hrsh7th/cmp-path",
    },
    config = function()
      -- See `:help cmp`
      local cmp = require("cmp")
      local luasnip = require("luasnip")
      luasnip.config.setup({})

      cmp.setup({
        snippet = {
          expand = function(args)
            luasnip.lsp_expand(args.body)
          end,
        },
        completion = { completeopt = "menu,menuone,noinsert" },
        performance = {
          debug = true,
        },
        sorting = {
          priority_weight = 2,
          comparators = {
            -- Below is the default comparitor list and order for nvim-cmp
            cmp.config.compare.offset,
            -- cmp.config.compare.scopes, --this is commented in nvim-cmp too
            cmp.config.compare.exact,
            cmp.config.compare.score,
            cmp.config.compare.recently_used,
            cmp.config.compare.locality,
            cmp.config.compare.kind,
            cmp.config.compare.sort_text,
            cmp.config.compare.length,
            cmp.config.compare.order,
          },
        },

        -- For an understanding of why these mappings were
        -- chosen, you will need to read `:help ins-completion`
        --
        -- No, but seriously. Please read `:help ins-completion`, it is really good!
        mapping = cmp.mapping.preset.insert({
          -- Select the [n]ext item
          ["<C-n>"] = cmp.mapping.select_next_item(),
          -- Select the [p]revious item
          ["<C-p>"] = cmp.mapping.select_prev_item(),

          -- Scroll the documentation window [b]ack / [f]orward
          ["<C-b>"] = cmp.mapping.scroll_docs(-4),
          ["<C-f>"] = cmp.mapping.scroll_docs(4),

          -- Accept ([y]es) the completion.
          --  This will auto-import if your LSP supports it.
          --  This will expand snippets if the LSP sent a snippet.
          ["<C-y>"] = cmp.mapping.confirm({ select = true }),

          -- Manually trigger a completion from nvim-cmp.
          --  Generally you don't need this, because nvim-cmp will display
          --  completions whenever it has completion options available.
          ["<C-Space>"] = cmp.mapping.complete({}),

          -- Think of <c-l> as moving to the right of your snippet expansion.
          --  So if you have a snippet that's like:
          --  function $name($args)
          --    $body
          --  end
          --
          -- <c-l> will move you to the right of each of the expansion locations.
          -- <c-h> is similar, except moving you backwards.
          ["<C-l>"] = cmp.mapping(function()
            if luasnip.expand_or_locally_jumpable() then
              luasnip.expand_or_jump()
            end
          end, { "i", "s" }),
          ["<C-h>"] = cmp.mapping(function()
            if luasnip.locally_jumpable(-1) then
              luasnip.jump(-1)
            end
          end, { "i", "s" }),

          -- For more advanced Luasnip keymaps (e.g. selecting choice nodes, expansion) see:
          --    https://github.com/L3MON4D3/LuaSnip?tab=readme-ov-file#keymaps
        }),
        sources = {
          { name = "nvim_lsp", group_index = 2 },
          { name = "luasnip", group_index = 2 },
          { name = "path", group_index = 2 },
        },
      })
    end,
  },
})

-- Line numbers
vim.opt.number = false
vim.opt.signcolumn = "yes"

-- Folds
vim.opt.foldlevel = 99
vim.opt.foldmethod = "manual"

-- Display
-- Load tinty-generated colorscheme
vim.cmd([[source ~/.local/share/tinted-theming/tinty/artifacts/vim-colors-file.vim]])

-- To identify highlight groups and their names:
--   - Place cursor on an element and run `:Inspect` to see the highlight group(s)
--   - Run `:InspectTree` to see the TreeSitter syntax tree and node types
--   - Highlight group names like "@markup.heading.1.markdown" come from TreeSitter

-- Custom markdown highlights using tinted-vim highlight groups
-- These automatically adapt to any theme applied via tinty
vim.api.nvim_set_hl(0, "@markup.heading.1.markdown", { link = "Constant" }) -- orange (gui09)
vim.api.nvim_set_hl(0, "@markup.heading.2.markdown", { link = "tinted_gui0C" }) -- cyan
vim.api.nvim_set_hl(0, "@markup.heading.3.markdown", { link = "String" }) -- green (gui0B)
vim.api.nvim_set_hl(0, "@markup.heading.4.markdown", { link = "Statement" }) -- magenta/pink (gui0E)
vim.api.nvim_set_hl(0, "@markup.link.url.markdown_inline", { link = "Comment" }) -- comment (gui03)
vim.api.nvim_set_hl(0, "@markup.list", { link = "Statement" }) -- purple/magenta (gui0E)
vim.api.nvim_set_hl(0, "@markup.raw.markdown_inline", { link = "Type" }) -- yellow (gui0A)
vim.api.nvim_set_hl(0, "@markup.strong.markdown_inline", { link = "Statement" }) -- magenta (gui0E)

-- Inherit from @markup.italic but add underline
local italic_highlight = vim.api.nvim_get_hl(0, { name = "@markup.italic" })
vim.api.nvim_set_hl(0, "@markup.quote.markdown", italic_highlight)
italic_highlight.underline = true
vim.api.nvim_set_hl(0, "@markup.italic.markdown_inline", italic_highlight)

-- Link Special to Function (blue, gui0D)
vim.api.nvim_set_hl(0, "Special", { link = "Function" })

vim.api.nvim_set_hl(0, "SpellRare", { link = "SpellBad" })
vim.api.nvim_set_hl(0, "SpellCap", { link = "SpellBad" })
vim.api.nvim_set_hl(0, "SpellLocal", { link = "SpellBad" })

vim.opt.scrolloff = 2
vim.opt.splitbelow = true
vim.opt.splitright = true
vim.opt.wrap = true

-- Search
vim.opt.ignorecase = true
vim.opt.mouse = ""
vim.opt.smartcase = true

-- Navigation Keymaps
-- Initialize globals for storing tab indices
vim.g.last_tab = 1

-- Function to switch to the last active tab
local function toggle_tab()
  local last_tab = vim.g.last_tab or vim.fn.tabpagenr()
  -- Switch to the last tab if it's different from the current
  if last_tab ~= vim.fn.tabpagenr() then
    vim.cmd("tabn " .. last_tab)
  end
end

-- Set keymap for toggling to the last active tab
vim.keymap.set("n", "<Leader>pt", toggle_tab, { noremap = true, silent = true, desc = "[P]revious [T]ab" })

-- Autocommand to track tab changes
vim.cmd([[
  augroup TrackTabSwitch
    autocmd!
    autocmd TabLeave * let g:last_tab = tabpagenr()
  augroup END
]])

-- Window keymaps
vim.keymap.set("n", "<leader>h", ":nohlsearch<CR>", { desc = "Clear [H]ighlight" })
vim.keymap.set("n", "j", "gj", { noremap = true }) -- navigate long lines as multiple lines
vim.keymap.set("n", "k", "gk", { noremap = true }) -- navigate long lines as multiple lines

-- Code Keymaps
vim.keymap.set("n", "<leader>F", ":Format<CR>", { desc = "[F]ormat" })
vim.keymap.set("n", "<leader>fk", require("telescope.builtin").keymaps, { desc = "[F]ind [K]eymaps" })

-- Telescope Keymaps
local function switch_to_buffer(bufnr)
  -- Iterate over all tabs
  for tabnr = 1, vim.fn.tabpagenr("$") do
    -- Get all windows in the current tab
    local wins = vim.api.nvim_tabpage_list_wins(tabnr)
    -- In each tab, iterate over all windows
    for _, winid in ipairs(wins) do
      -- Get the buffer number for each window
      local winbufnr = vim.api.nvim_win_get_buf(winid)
      if winbufnr == bufnr then
        -- If the buffer number matches, switch to the tab and window
        vim.cmd("tabn " .. tabnr)
        vim.api.nvim_set_current_win(winid)
        return
      end
    end
  end
  -- If not found, open the buffer in the current window
  vim.api.nvim_set_current_buf(bufnr)
end

local builtin = require("telescope.builtin")
local actions = require("telescope.actions")
local action_state = require("telescope.actions.state")

vim.keymap.set("n", "<leader>fb", function()
  builtin.buffers({
    attach_mappings = function(prompt_bufnr, map)
      -- Redefine the selection behavior
      actions.select_default:replace(function()
        actions.close(prompt_bufnr)
        local selected_bufnr = action_state.get_selected_entry().bufnr
        switch_to_buffer(selected_bufnr)
      end)
      return true
    end,
    desc = "[F]ind [B]uffer",
  })
end)
vim.keymap.set("n", "<leader>fw", builtin.grep_string, { desc = "[F]ind [W]ord" })
vim.keymap.set("n", "<leader>ff", builtin.find_files, { desc = "[F]ind [F]ile" })
vim.keymap.set("n", "<leader>fF", function()
  builtin.find_files({
    hidden = true,
    no_ignore = true,
    no_ignore_parent = true,
  })
end, { desc = "[F]ind All [F]iles" })
vim.keymap.set("n", "<leader>fg", builtin.live_grep, { desc = "[F]ind [G]rep" })
vim.keymap.set("n", "<leader>pf", function()
  local site_packages = vim.fn.glob("./.venv/lib/*/site-packages")
  if site_packages ~= "" then
    local first_path = vim.split(site_packages, "\n")[1]
    builtin.find_files({
      cwd = first_path,
      hidden = true,
      no_ignore = true,
    })
  else
    print("No site-packages directory found in .venv")
  end
end, { desc = "[P]ython [F]ind" })

vim.keymap.set("n", "<leader>pg", function()
  local site_packages = vim.fn.glob("./.venv/lib/*/site-packages")
  if site_packages ~= "" then
    local first_path = vim.split(site_packages, "\n")[1]
    builtin.live_grep({
      cwd = first_path,
      additional_args = function(opts)
        return { "--hidden", "--no-ignore" }
      end,
    })
  else
    print("No site-packages directory found in .venv")
  end
end, { desc = "[P]ython [G]rep" })

vim.keymap.set("n", "<leader>pw", function()
  local site_packages = vim.fn.glob("./.venv/lib/*/site-packages")
  if site_packages ~= "" then
    local first_path = vim.split(site_packages, "\n")[1]
    builtin.grep_string({
      cwd = first_path,
      additional_args = function(opts)
        return { "--hidden", "--no-ignore" }
      end,
    })
  else
    print("No site-packages directory found in .venv")
  end
end, { desc = "[P]ython [W]ord" })

vim.keymap.set("n", "<leader>gd", function()
  vim.cmd("vsplit")
  vim.lsp.buf.definition()

  -- Wait a bit longer
  vim.defer_fn(function()
    vim.cmd("normal! zt")
  end, 200) -- 200ms delay
end, { desc = "[G]o to [D]efinition in vertical split at top" })

-- Toggle Zen mode
local zentoggle = function()
  require("zen-mode").toggle({
    window = {
      width = 106,
    },
    plugins = {
      gitsigns = {
        enabled = true,
      },
    },
  })
end
vim.keymap.set("n", "<leader>z", zentoggle, { desc = "[Z]en Mode" })

-- Snippets
require("luasnip.loaders.from_snipmate").lazy_load({ paths = { vim.fn.stdpath("config") .. "/snippets" } })
require("luasnip").filetype_extend("typescript", { "javascript" })
require("luasnip").filetype_extend("typescriptreact", { "javascript" })
vim.keymap.set("n", "<leader>es", require("luasnip.loaders").edit_snippet_files, { desc = "[E]dit [S]nippets" })
local snipsetuppath = vim.fn.stdpath("config") .. "/luasnip.vim"
vim.cmd("source " .. snipsetuppath)

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
    map("n", "<leader>hs", gs.stage_hunk, { silent = true, desc = "[H]unk [S]tage" })
    map("n", "<leader>hr", gs.reset_hunk, { silent = true, desc = "[H]unk [R]eset" })
    map("v", "<leader>hs", function()
      gs.stage_hunk({ vim.fn.line("."), vim.fn.line("v") })
    end, { silent = true, desc = "[H]unk [S]tage" })
    map("v", "<leader>hr", function()
      gs.reset_hunk({ vim.fn.line("."), vim.fn.line("v") })
    end, { silent = true, desc = "[H]unk [R]eset" })
    map("n", "<leader>hS", gs.stage_buffer, { silent = true, desc = "[H]unk [S]tage Buffer" })
    map("n", "<leader>hu", gs.undo_stage_hunk, { silent = true, desc = "[H]unk [U]ndo Stage" })
    map("n", "<leader>hR", gs.reset_buffer, { silent = true, desc = "[H]unk [R]eset Buffer" })
    map("n", "<leader>hp", gs.preview_hunk, { silent = true, desc = "[H]unk [P]review" })
    map("n", "<leader>hb", function()
      gs.blame_line({ full = true })
    end, { silent = true, desc = "[H]unk [B]lame" })
    map("n", "<leader>tb", gs.toggle_current_line_blame, { silent = true, desc = "[T]oggle [B]lame" })
    map("n", "<leader>hd", gs.diffthis, { silent = true, desc = "[H]unk [D]iff" })
    map("n", "<leader>hD", function()
      gs.diffthis("~")
    end, { silent = true, desc = "[H]unk [D]iff Buffer" })
    map("n", "<leader>td", gs.toggle_deleted, { silent = true, desc = "[T]oggle [D]eleted" })

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

-- leap.nvim setup
vim.keymap.set({ "n", "x", "o" }, "<leader>s", "<Plug>(leap)", { silent = true, desc = "Leap [S]earch" })

---- Buffers
--Bufferline setup
vim.opt.termguicolors = true
require("bufferline").setup({})
-- bufdel setup
require("bufdel").setup({
  next = "cycle",
  quit = false,
})
-- buffer commands
vim.keymap.set("n", "<leader>$", ":BufferLineGoToBuffer -1<CR>", { silent = true, desc = "Go To Last Buffer" })
vim.keymap.set("n", "<leader>1", ":BufferLineGoToBuffer 1<CR>", { silent = true, desc = "Go To Buffer 1" })
vim.keymap.set("n", "<leader>2", ":BufferLineGoToBuffer 2<CR>", { silent = true, desc = "Go To Buffer 2" })
vim.keymap.set("n", "<leader>3", ":BufferLineGoToBuffer 3<CR>", { silent = true, desc = "Go To Buffer 3" })
vim.keymap.set("n", "<leader>4", ":BufferLineGoToBuffer 4<CR>", { silent = true, desc = "Go To Buffer 4" })
vim.keymap.set("n", "<leader>5", ":BufferLineGoToBuffer 5<CR>", { silent = true, desc = "Go To Buffer 5" })
vim.keymap.set("n", "<leader>6", ":BufferLineGoToBuffer 6<CR>", { silent = true, desc = "Go To Buffer 6" })
vim.keymap.set("n", "<leader>7", ":BufferLineGoToBuffer 7<CR>", { silent = true, desc = "Go To Buffer 7" })
vim.keymap.set("n", "<leader>8", ":BufferLineGoToBuffer 8<CR>", { silent = true, desc = "Go To Buffer 8" })
vim.keymap.set("n", "<leader>9", ":BufferLineGoToBuffer 9<CR>", { silent = true, desc = "Go To Buffer 9" })
vim.keymap.set("n", "<leader>bP", ":BufferLineTogglePin<CR>", { silent = true, desc = "[B]uffer [P]in" })
vim.keymap.set("n", "[b", ":BufferLineCyclePrev<CR>", { silent = true, desc = "[B]uffer [B]ack" })
vim.keymap.set("n", "<leader>bh", ":BufferLineCloseLeft<CR>", { silent = true, desc = "[B]uffer Close Left" })
vim.keymap.set("n", "<leader>bl", ":BufferLineCloseRight<CR>", { silent = true, desc = "[B]uffer Close Right" })
vim.keymap.set("n", "]b", ":BufferLineCycleNext<CR>", { silent = true, desc = "[B]uffer [N]ext" })
vim.keymap.set("n", "<leader>bo", ":BufferLineCloseOthers<CR>", { silent = true, desc = "[B]uffer Close [O]thers" })
vim.keymap.set("n", "<leader>bp", ":BufferLinePick<CR>", { silent = true, desc = "[B]uffer [P]ick" })
vim.keymap.set("n", "<leader>c", ":BufDel<CR>", { silent = true, desc = "[C]lear Buffer" })
vim.keymap.set("n", "<leader>q", function()
  vim.cmd("q")
end, { desc = "[Q]uit" })

---- LSP Config
--Diagnostic keymaps
vim.keymap.set("n", "[d", vim.diagnostic.goto_prev, { desc = "Go to previous [D]iagnostic message" })
vim.keymap.set("n", "]d", vim.diagnostic.goto_next, { desc = "Go to next [D]iagnostic message" })
vim.keymap.set("n", "<leader>e", vim.diagnostic.open_float, { desc = "Show diagnostic [E]rror messages" })
vim.keymap.set("n", "<leader>gq", vim.diagnostic.setloclist, { desc = "Open diagnostic [Q]uickfix list" })

-- Remember current position
local scrollpath = vim.fn.stdpath("config") .. "/scroll.vim"
vim.cmd("source " .. scrollpath)

-- Keybindings for whisper voice-to-text
local whisper = require("whisper")
vim.keymap.set("i", "<C-s>", function()
  whisper.insert_transcription()
end, { desc = "[S]peech to text (insert mode)" })
vim.keymap.set("n", "<C-s>", function()
  whisper.normal_transcription()
end, { desc = "[S]peech to text (normal mode)" })
vim.keymap.set("v", "<C-s>", function()
  whisper.replace_selection()
end, { desc = "[S]peech to text (visual mode)" })

-- Keybindings for note-taking functions
local garden = require("garden")
vim.keymap.set("n", "<leader>gn", garden.new_note, { desc = "[G]arden [N]ew" })
vim.keymap.set("n", "<leader>gg", garden.go_today, { desc = "[G]arden [G]o: Today" })
vim.keymap.set("n", "[g", garden.go_previous_diary, { desc = "Garden [G]o: Previous" })
vim.keymap.set("n", "]g", garden.go_next_diary, { desc = "Garden [G]o: Next" })
vim.keymap.set("n", "<leader>fh", garden.find_header, { desc = "[F]ind [H]eader" })
vim.keymap.set("n", "<leader>fl", garden.find_link, { desc = "[F]ind [L]ink" })
vim.keymap.set(
  "n",
  "<leader>fp",
  garden.insert_timestamped_project_entry,
  { desc = "[F]ind [P]roject (with timestamp)" }
)
vim.keymap.set("n", "<C-t>", garden.toggle_todo, { desc = "Complete [T]ask" })

-- Markdown specific changes
vim.api.nvim_create_autocmd({ "BufRead", "BufNewFile" }, {
  pattern = { "*.txt", "*.md", "*.markdown" },
  callback = function()
    vim.opt_local.spell = false
    vim.opt_local.spelllang = "en_us"
    -- Setup markdown-specific vim-surround mappings
    require("garden").setup_markdown_surround()
  end,
})

---@diagnostic disable-next-line: undefined-global
local vim = vim

vim.g.mapleader = " " -- Make sure to set `mapleader` before plugins so mappings are correct

-- Install plugins via vim.pack (native, Neovim 0.12+)
vim.pack.add({
  { src = "https://github.com/akinsho/bufferline.nvim" },
  { src = "https://github.com/nvim-tree/nvim-web-devicons" },
  { src = "https://github.com/christoomey/vim-tmux-navigator" },
  { src = "https://github.com/folke/zen-mode.nvim" },
  { src = "https://codeberg.org/andyg/leap.nvim" },
  { src = "https://github.com/lewis6991/gitsigns.nvim" },
  { src = "https://github.com/micarmst/vim-spellsync" },
  { src = "https://github.com/tinted-theming/tinted-vim" },
  { src = "https://github.com/nvim-lua/plenary.nvim" },
  { src = "https://github.com/nvim-telescope/telescope.nvim" },
  { src = "https://github.com/nvim-telescope/telescope-fzf-native.nvim" },
  { src = "https://github.com/nvim-treesitter/nvim-treesitter" },
  { src = "https://github.com/ojroques/nvim-bufdel" },
  { src = "https://github.com/RRethy/vim-illuminate" },
  { src = "https://github.com/kylechui/nvim-surround" },
  { src = "https://github.com/windwp/nvim-autopairs" },
  { src = "https://github.com/stevearc/conform.nvim" },
  { src = "https://github.com/L3MON4D3/LuaSnip" },
  -- LuaSnip note: if regex-transform snippets are ever needed, run once manually:
  --   make -C ~/.local/share/nvim/site/pack/core/opt/LuaSnip install_jsregexp
  { src = "https://github.com/HiPhish/rainbow-delimiters.nvim" },
})

-- Build hooks: run after plugin install/update
vim.api.nvim_create_autocmd("PackChanged", {
  callback = function(args)
    if args.data.kind == "install" or args.data.kind == "update" then
      local name = args.data.spec.name
      if name == "nvim-treesitter" then
        vim.cmd("TSUpdate")
      elseif name == "telescope-fzf-native.nvim" then
        vim.fn.system({ "make", "-C", args.data.path })
      end
    end
  end,
})

-- Enable TreeSitter highlighting for file buffers
vim.api.nvim_create_autocmd({ "FileType" }, {
  callback = function(args)
    -- Skip special buffers (plugins, help, etc.)
    local buftype = vim.bo[args.buf].buftype
    if buftype ~= "" then
      return
    end

    -- Try to start TreeSitter, silently ignore if parser not available
    local ok, err = pcall(vim.treesitter.start, args.buf)
    -- Uncomment to see warnings when parsers are missing:
    -- if not ok then
    --   vim.notify("TreeSitter parser not available for " .. vim.bo.filetype, vim.log.levels.WARN)
    -- end
  end,
})

-- LSP Configuration
--
-- LSP stands for Language Server Protocol. It enables features like:
--  - Go to definition
--  - Find references
--  - Symbol Search
--  - and more!
--
-- Language Servers are external tools that must be installed separately from Neovim.
-- LSP servers, formatters, and tree-sitter CLI are managed by mise
-- (see mise/.config/mise/config.toml).
--
-- If you're wondering about lsp vs treesitter, you can check out the wonderfully
-- and elegantly composed help section, `:help lsp-vs-treesitter`

-- This autocmd runs when an LSP attaches to a particular buffer.
vim.api.nvim_create_autocmd("LspAttach", {
  group = vim.api.nvim_create_augroup("kickstart-lsp-attach", { clear = true }),
  callback = function(event)
    local map = function(keys, func, desc)
      vim.keymap.set("n", keys, func, { buffer = event.buf, desc = "LSP: " .. desc })
    end

    -- Jump to the definition of the word under your cursor.
    -- To jump back, press <C-t>.
    map("gd", vim.lsp.buf.definition, "[G]oto [D]efinition")

    -- Rename the variable under your cursor.
    map("<leader>rn", vim.lsp.buf.rename, "[R]e[n]ame")

    -- Execute a code action (cursor on error/suggestion).
    map("<leader>oa", vim.lsp.buf.code_action, "C[o]de [A]ction")

    -- Manual LSP completion trigger (insert mode)
    local client = vim.lsp.get_client_by_id(event.data.client_id)
    if client and client:supports_method("textDocument/completion") then
      vim.lsp.completion.enable(true, client.id, event.buf, { autotrigger = false })
      vim.keymap.set("i", "<C-Space>", function()
        vim.lsp.completion.get()
      end, { buffer = event.buf, desc = "LSP completion" })
    end
  end,
})

-- LSP capabilities (plain, no cmp dependency)
local capabilities = vim.lsp.protocol.make_client_capabilities()

-- LSP server commands
-- LSP servers, formatters, and tree-sitter CLI are managed by mise
-- (see mise/.config/mise/config.toml).
local server_commands = {
  lua_ls = { "lua-language-server" },
  ty = { "ty", "server" },
  ts_ls = { "typescript-language-server", "--stdio" },
  htmx = { "htmx-lsp", "--level", "DEBUG" },
}

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

-- Line numbers
vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.signcolumn = "yes"

-- Folds
vim.opt.foldlevel = 99
vim.opt.foldmethod = "manual"

-- Display
-- Load tinty-generated colorscheme
vim.cmd([[source ~/.local/share/tinted-theming/tinty/artifacts/vim-colors-file.vim]])
vim.opt.winborder = "rounded"

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
-- Navigate wrapped lines as display lines, but use actual lines with a count (e.g. 20j)
vim.keymap.set("n", "j", function()
  return vim.v.count == 0 and "gj" or "j"
end, { noremap = true, expr = true })
vim.keymap.set("n", "k", function()
  return vim.v.count == 0 and "gk" or "k"
end, { noremap = true, expr = true })

-- Code Keymaps
vim.keymap.set("n", "<leader>F", function()
  require("conform").format()
end, { desc = "[F]ormat" })
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

-- LuaSnip standalone keymaps (expand/jump without cmp)
vim.keymap.set({ "i", "s" }, "<C-l>", function()
  local luasnip = require("luasnip")
  if luasnip.expand_or_locally_jumpable() then
    luasnip.expand_or_jump()
  end
end, { desc = "Snippet expand/jump forward" })

vim.keymap.set({ "i", "s" }, "<C-h>", function()
  local luasnip = require("luasnip")
  if luasnip.locally_jumpable(-1) then
    luasnip.jump(-1)
  end
end, { desc = "Snippet jump backward" })

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
-- Load fzf native extension for faster matching
require("telescope").load_extension("fzf")

-- leap.nvim setup
vim.keymap.set({ "n", "x", "o" }, "<leader>s", "<Plug>(leap)", { silent = true, desc = "Leap [S]earch" })

---- Buffers
--Bufferline setup
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
vim.keymap.set("n", "<leader>gf", garden.find_diary, { desc = "[G]arden [F]ile" })
vim.keymap.set("n", "<leader>fh", garden.find_header, { desc = "[F]ind [H]eader" })
vim.keymap.set("n", "<leader>fl", garden.find_link, { desc = "[F]ind [L]ink" })
vim.keymap.set("n", "<leader>gl", garden.garden_log, { desc = "[G]arden [L]og" })
vim.keymap.set("n", "<leader>gL", garden.garden_log_project, { desc = "[G]arden [L]og Project" })
vim.keymap.set("n", "<C-t>", garden.toggle_todo, { desc = "Complete [T]ask" })

-- nvim-surround setup (replaces vim-surround; treesitter-aware)
-- Note: garden.lua's setup_markdown_surround() uses nvim-surround's buffer_setup API
require("nvim-surround").setup({})

-- nvim-autopairs (eager setup — negligible startup cost)
require("nvim-autopairs").setup({})

-- conform.nvim (formatter)
require("conform").setup({
  notify_on_error = false,
  formatters_by_ft = {
    lua = { "stylua" },
    markdown = { "prettier" },
  },
})

-- Markdown specific changes
vim.api.nvim_create_autocmd({ "BufRead", "BufNewFile" }, {
  pattern = { "*.txt", "*.md", "*.markdown" },
  callback = function()
    vim.opt_local.spell = false
    vim.opt_local.spelllang = "en_us"
    -- Setup markdown-specific nvim-surround mappings (e.g. bold wrap with ysiwb -> **...**)
    require("garden").setup_markdown_surround()
  end,
})

-- YAML specific changes
vim.api.nvim_create_autocmd("FileType", {
  pattern = "yaml",
  callback = function()
    vim.opt_local.foldmethod = "indent"
  end,
})

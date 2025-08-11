---@diagnostic disable-next-line: undefined-global
local vim = vim

local M = {}

-- Garden directory paths
local GARDEN_DIR = "~/dev/garden"
local DIARY_DIR = GARDEN_DIR .. "/diary"

-- Create a new unique note in ~/dev/garden/ with timestamp filename
function M.new_note()
  -- Get current timestamp in YYYYMMDDHHMM format
  local timestamp = os.date("%Y%m%d%H%M")
  local filename = timestamp .. ".md"
  local filepath = vim.fn.expand(GARDEN_DIR .. "/" .. filename)

  -- Create the directory if it doesn't exist
  vim.fn.mkdir(vim.fn.expand(GARDEN_DIR), "p")

  -- Open the new file
  vim.cmd("edit " .. filepath)
end

-- Navigate to today's diary entry
function M.go_today()
  -- Get today's date in YYYY-MM-DD format
  local today = os.date("%Y-%m-%d")
  local filename = today .. ".md"
  local filepath = vim.fn.expand(DIARY_DIR .. "/" .. filename)

  -- Check if the file exists
  if vim.fn.filereadable(filepath) == 1 then
    vim.cmd("edit " .. filepath)
  else
    vim.notify("Today's diary entry does not exist: " .. filename, vim.log.levels.INFO)
  end
end

-- Helper function to get current diary date reference
local function get_current_diary_date()
  local diary_dir_expanded = vim.fn.expand(DIARY_DIR .. "/")
  local current_file = vim.fn.expand("%:p")

  -- Check if current buffer is a diary file
  if string.match(current_file, vim.pesc(diary_dir_expanded)) then
    -- Extract date from current diary file
    local filename = vim.fn.expand("%:t:r") -- get filename without extension
    if string.match(filename, "^%d%d%d%d%-%d%d%-%d%d$") then
      return filename
    end
  end

  -- Not a diary file or invalid format, use today's date
  return os.date("%Y-%m-%d")
end

-- Helper function to get all diary files sorted chronologically
local function get_sorted_diary_files()
  local diary_dir_expanded = vim.fn.expand(DIARY_DIR .. "/")
  local diary_files = vim.fn.glob(diary_dir_expanded .. "*.md", false, true)
  table.sort(diary_files)
  return diary_files
end

-- Go to previous diary entry
function M.go_previous_diary()
  local current_date = get_current_diary_date()
  local diary_files = get_sorted_diary_files()

  -- Find the previous diary file
  local previous_file = nil
  for _, file in ipairs(diary_files) do
    local file_date = vim.fn.fnamemodify(file, ":t:r")
    if string.match(file_date, "^%d%d%d%d%-%d%d%-%d%d$") and file_date < current_date then
      previous_file = file
    elseif file_date >= current_date then
      break
    end
  end

  if previous_file then
    vim.cmd("edit " .. previous_file)
  else
    vim.notify("No previous diary entry found", vim.log.levels.INFO)
  end
end

-- Go to next diary entry
function M.go_next_diary()
  local current_date = get_current_diary_date()
  local diary_files = get_sorted_diary_files()

  -- Find the next diary file
  local next_file = nil
  for _, file in ipairs(diary_files) do
    local file_date = vim.fn.fnamemodify(file, ":t:r")
    if string.match(file_date, "^%d%d%d%d%-%d%d%-%d%d$") and file_date > current_date then
      next_file = file
      break
    end
  end

  if next_file then
    vim.cmd("edit " .. next_file)
  else
    vim.notify("No next diary entry found", vim.log.levels.INFO)
  end
end

-- Helper function to create telescope markdown header search
local function create_header_telescope(on_select)
  local telescope = require("telescope.builtin")
  local actions = require("telescope.actions")
  local action_state = require("telescope.actions.state")

  telescope.live_grep({
    default_text = "#.*",
    glob_pattern = "*.md",
    additional_args = function(opts)
      return { "--smart-case" }
    end,
    attach_mappings = function(prompt_bufnr, map)
      actions.select_default:replace(function()
        local selection = action_state.get_selected_entry()
        actions.close(prompt_bufnr)
        on_select(selection)
      end)
      return true
    end,
  })
end

-- Search for markdown headers
function M.find_header()
  create_header_telescope(function(selection)
    -- Open the file and jump to the line
    vim.cmd("edit " .. selection.filename)
    vim.api.nvim_win_set_cursor(0, { selection.lnum, 0 })
  end)
end

-- Search notes and create markdown link
function M.find_link()
  create_header_telescope(function(selection)
    -- Get the file path relative to current working directory
    local cwd = vim.fn.getcwd()
    local relative_path = vim.fn.fnamemodify(selection.filename, ":.")

    -- Extract the header from the selected line (any level)
    local line_content = selection.text or ""
    local header = string.match(line_content, "^#+%s+(.+)")

    if header then
      -- Create markdown link
      local markdown_link = "[" .. header .. "](" .. relative_path .. ")"

      -- Insert at cursor position
      local cursor = vim.api.nvim_win_get_cursor(0)
      local row, col = cursor[1], cursor[2]
      vim.api.nvim_buf_set_text(0, row - 1, col, row - 1, col, { markdown_link })

      -- Move cursor to end of inserted text
      vim.api.nvim_win_set_cursor(0, { row, col + #markdown_link })
    else
      vim.notify("No valid header found in selected line", vim.log.levels.WARN)
    end
  end)
end

-- Toggle markdown todo completion status
function M.toggle_todo()
  local cursor = vim.api.nvim_win_get_cursor(0)
  local row = cursor[1]
  local line = vim.api.nvim_buf_get_lines(0, row - 1, row, false)[1]

  if not line then
    return
  end

  local new_line
  -- Check if it's an incomplete todo: - [ ]
  if string.match(line, "^%s*%- %[ %]") then
    new_line = string.gsub(line, "^(%s*%- )%[ %]", "%1[x]")
  -- Check if it's a complete todo: - [x]
  elseif string.match(line, "^%s*%- %[x%]") then
    new_line = string.gsub(line, "^(%s*%- )%[x%]", "%1[ ]")
  else
    -- Not a todo item, do nothing
    return
  end

  -- Replace the line
  vim.api.nvim_buf_set_lines(0, row - 1, row, false, { new_line })
end

-- Setup markdown-specific vim-surround mappings
function M.setup_markdown_surround()
  -- Custom vim-surround mapping for markdown bold (**)
  -- 98 is ASCII code for 'b' - use Sb to surround with **text**
  vim.b.surround_98 = "**\r**"
end

-- Find project from topics file and insert formatted template
function M.find_project()
  local project_file = vim.fn.expand("~/dev/garden/topics/202508111053.md")
  
  -- Check if file exists
  if vim.fn.filereadable(project_file) == 0 then
    vim.notify("Project file not found: " .. project_file, vim.log.levels.ERROR)
    return
  end
  
  -- Read and parse the file
  local lines = vim.fn.readfile(project_file)
  local projects = {}
  
  for _, line in ipairs(lines) do
    -- Match bullet points: - Project Name, * Project Name, + Project Name
    local project = string.match(line, "^%s*[%-%*%+]%s+(.+)")
    if project then
      -- Trim whitespace
      project = string.gsub(project, "^%s*(.-)%s*$", "%1")
      if project ~= "" then
        table.insert(projects, project)
      end
    end
  end
  
  if #projects == 0 then
    vim.notify("No projects found in file", vim.log.levels.WARN)
    return
  end
  
  -- Create Telescope picker
  local pickers = require("telescope.pickers")
  local finders = require("telescope.finders")
  local conf = require("telescope.config").values
  local actions = require("telescope.actions")
  local action_state = require("telescope.actions.state")
  
  pickers.new({}, {
    prompt_title = "Find Project",
    finder = finders.new_table({
      results = projects
    }),
    sorter = conf.generic_sorter({}),
    attach_mappings = function(prompt_bufnr, map)
      actions.select_default:replace(function()
        actions.close(prompt_bufnr)
        local selection = action_state.get_selected_entry()
        if selection then
          -- Format and insert the project name
          local formatted_text = "**" .. selection[1] .. "**:"
          
          -- Insert at cursor position
          local cursor = vim.api.nvim_win_get_cursor(0)
          local row, col = cursor[1], cursor[2]
          vim.api.nvim_buf_set_text(0, row - 1, col, row - 1, col, { formatted_text })
          
          -- Move cursor to end of inserted text
          vim.api.nvim_win_set_cursor(0, { row, col + #formatted_text })
        end
      end)
      return true
    end,
  }):find()
end

return M

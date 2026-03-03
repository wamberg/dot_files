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

-- Find the line number after all entries in the "## Log" section
-- Returns nil if section not found
local function find_log_section_end()
  local lines = vim.api.nvim_buf_get_lines(0, 0, -1, false)
  local log_section_start = nil
  local last_entry_line = nil

  for i, line in ipairs(lines) do
    -- Find "## Log" header
    if log_section_start == nil and string.match(line, "^## Log%s*$") then
      log_section_start = i
      last_entry_line = i
    elseif log_section_start then
      -- Check if we hit another H2 section (end of Log section)
      if string.match(line, "^## ") then
        break
      end
      -- Track any non-empty line as potential last entry
      if line ~= "" then
        last_entry_line = i
      end
    end
  end

  return log_section_start and last_entry_line or nil
end

-- Telescope picker for diary entries, sorted reverse-chronologically
-- Searching "monday" shows most recent Mondays first, etc.
function M.find_diary()
  local pickers = require("telescope.pickers")
  local finders = require("telescope.finders")
  local conf = require("telescope.config").values
  local sorters = require("telescope.sorters")
  local actions = require("telescope.actions")
  local action_state = require("telescope.actions.state")

  local diary_files = get_sorted_diary_files()
  local entries = {}
  local total = #diary_files

  for i = #diary_files, 1, -1 do -- reverse chronological
    local file = diary_files[i]
    local date_str = vim.fn.fnamemodify(file, ":t:r") -- "2024-03-15"
    local y, m, d = date_str:match("(%d+)-(%d+)-(%d+)")
    if y then
      local time = os.time({ year = y, month = m, day = d })
      local display = os.date("%A, %B %d, %Y", time) -- "Friday, March 15, 2024"
      -- recency_rank: 0 for most recent, 1 for oldest
      local recency_rank = (#diary_files - i) / total
      table.insert(entries, { display = display, date = date_str, path = file, recency_rank = recency_rank })
    end
  end

  -- Custom sorter: base fuzzy score + small recency bonus so that
  -- equally-matched entries (e.g. all "Monday"s) sort most-recent-first.
  local base_sorter = conf.generic_sorter({})

  local recency_sorter = sorters.Sorter:new({
    discard = base_sorter.discard,
    scoring_function = function(self, prompt, line, entry, cb_add, cb_filter)
      local base_score = base_sorter:scoring_function(prompt, line, entry, cb_add, cb_filter)
      if base_score < 0 then
        return -1 -- filtered out
      end
      -- Add a tiny recency nudge (0 to 0.999) so recent entries win ties.
      -- Telescope sorts lower scores first, so recent entries get smaller nudge.
      local rank = (entry.value and entry.value.recency_rank) or 0
      return base_score + rank * 0.999
    end,
    highlighter = base_sorter.highlighter,
  })

  pickers
    .new({}, {
      prompt_title = "Diary Entries",
      finder = finders.new_table({
        results = entries,
        entry_maker = function(entry)
          return {
            value = entry,
            display = entry.date .. "  " .. entry.display,
            ordinal = entry.date .. " " .. entry.display,
            path = entry.path,
          }
        end,
      }),
      sorter = recency_sorter,
      previewer = conf.file_previewer({}),
      attach_mappings = function(prompt_bufnr)
        actions.select_default:replace(function()
          actions.close(prompt_bufnr)
          local selection = action_state.get_selected_entry()
          vim.cmd("edit " .. selection.value.path)
        end)
        return true
      end,
    })
    :find()
end

-- Setup markdown-specific vim-surround mappings
function M.setup_markdown_surround()
  -- Custom vim-surround mapping for markdown bold (**)
  -- 98 is ASCII code for 'b' - use Sb to surround with **text**
  vim.b.surround_98 = "**\r**"
end

-- Helper function to show project picker and execute callback with selected project
local function show_project_picker(callback)
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

  pickers
    .new({}, {
      prompt_title = "Find Project",
      finder = finders.new_table({
        results = projects,
      }),
      sorter = conf.generic_sorter({}),
      attach_mappings = function(prompt_bufnr, map)
        actions.select_default:replace(function()
          actions.close(prompt_bufnr)
          local selection = action_state.get_selected_entry()
          if selection then
            callback(selection[1])
          end
        end)
        return true
      end,
    })
    :find()
end

-- Find project from topics file and insert formatted template
function M.find_project()
  show_project_picker(function(project_name)
    -- Format and insert the project name
    local formatted_text = "_" .. project_name .. "_"

    -- Insert at cursor position
    local cursor = vim.api.nvim_win_get_cursor(0)
    local row, col = cursor[1], cursor[2]
    vim.api.nvim_buf_set_text(0, row - 1, col, row - 1, col, { formatted_text })

    -- Move cursor to end of inserted text
    vim.api.nvim_win_set_cursor(0, { row, col + #formatted_text })
  end)
end

-- Insert timestamped project entry with format: ### HH:MM - _ProjectName_
function M.insert_timestamped_project_entry()
  show_project_picker(function(project_name)
    -- Get current timestamp
    local timestamp = os.date("%H:%M")

    -- Get current cursor position
    local cursor = vim.api.nvim_win_get_cursor(0)
    local row = cursor[1]

    -- Get the current line and move to the end of it
    local current_line = vim.api.nvim_buf_get_lines(0, row - 1, row, false)[1]
    local col = #current_line -- End of the line

    -- Format the complete entry - split into lines for nvim_buf_set_text
    -- Two newlines before, timestamp line, two newlines after
    local formatted_lines = {
      "",
      "",
      "### " .. timestamp .. " - _" .. project_name .. "_",
      "",
      "",
    }

    -- Insert at end of current line
    vim.api.nvim_buf_set_text(0, row - 1, col, row - 1, col, formatted_lines)

    -- Calculate new cursor position (after all the lines)
    local new_row = row + 4 -- Move down 4 lines (2 before + timestamp + 2 after, cursor on last line)
    local new_col = 0 -- Start of the line

    vim.api.nvim_win_set_cursor(0, { new_row, new_col })

    -- Enter insert mode - schedule to ensure cursor positioning completes first
    vim.schedule(function()
      vim.cmd("startinsert")
    end)
  end)
end

-- Insert a timestamped log entry in the ## Log section
function M.garden_log()
  local last_entry_line = find_log_section_end()

  if not last_entry_line then
    vim.notify("No '## Log' section found in document", vim.log.levels.ERROR)
    return
  end

  local timestamp = os.date("%H:%M")
  local formatted_lines = { "", "### " .. timestamp, "", "" }

  -- Insert after the last entry line
  vim.api.nvim_buf_set_lines(0, last_entry_line, last_entry_line, false, formatted_lines)

  -- Position cursor on the second blank line (one blank line visible after header)
  local new_row = last_entry_line + 4 -- After blank + header + blank + cursor line
  vim.api.nvim_win_set_cursor(0, { new_row, 0 })

  vim.schedule(function()
    vim.cmd("startinsert")
  end)
end

-- Insert a timestamped project entry in the ## Log section
function M.garden_log_project()
  local last_entry_line = find_log_section_end()

  if not last_entry_line then
    vim.notify("No '## Log' section found in document", vim.log.levels.ERROR)
    return
  end

  show_project_picker(function(project_name)
    local timestamp = os.date("%H:%M")
    local formatted_lines = {
      "",
      "### " .. timestamp .. " - _" .. project_name .. "_",
      "",
      "",
    }

    -- Insert after the last entry line
    vim.api.nvim_buf_set_lines(0, last_entry_line, last_entry_line, false, formatted_lines)

    -- Position cursor on the second blank line (one blank line visible after header)
    local new_row = last_entry_line + 4
    vim.api.nvim_win_set_cursor(0, { new_row, 0 })

    vim.schedule(function()
      vim.cmd("startinsert")
    end)
  end)
end

return M

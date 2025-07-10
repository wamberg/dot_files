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

-- Search notes and create markdown link
function M.find_link()
  local telescope = require("telescope.builtin")
  local actions = require("telescope.actions")
  local action_state = require("telescope.actions.state")
  local garden_dir = vim.fn.expand(GARDEN_DIR)

  telescope.live_grep({
    cwd = garden_dir,
    default_text = "# ",
    attach_mappings = function(prompt_bufnr, map)
      actions.select_default:replace(function()
        local selection = action_state.get_selected_entry()
        actions.close(prompt_bufnr)

        -- Get the file path relative to garden directory
        local full_path = selection.filename
        local relative_path = string.gsub(full_path, "^" .. vim.pesc(garden_dir .. "/"), "")

        -- Extract the h1 header from the selected line
        local line_content = selection.text or ""
        local header = string.match(line_content, "^#%s+(.+)")

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
      return true
    end,
  })
end

return M

local actions = require "telescope.actions"
local action_state = require "telescope.actions.state"

local function link_post()
  local opts = {
    prompt_title = 'Link to',
    disable_coordinates = true,
    search = '^[#]+ ',
    use_regex = true,
    attach_mappings = function(prompt_bufnr)
      actions.select_default:replace(function()
        actions.close(prompt_bufnr)
        local selection = action_state.get_selected_entry()
        local current_buffer_filename = vim.fn.expand('%:p')
        current_buffer_filename = string.gsub(current_buffer_filename, GARDEN, '')

        -- Split the two file paths by '/'
        local src_parts = {}
        for part in string.gmatch(current_buffer_filename, "[^/]+") do
          table.insert(src_parts, part)
        end

        local dest_parts = {}
        for part in string.gmatch(selection.filename, "[^/]+") do
          table.insert(dest_parts, part)
        end

        -- Find the first index where the two paths differ
        local index = 1
        while src_parts[index] == dest_parts[index] do
          index = index + 1
        end

        -- Add '..' for each level up in the src path
        local relative_path = ""
        for i = index, #src_parts - 1 do
          relative_path = relative_path .. "../"
        end

        -- Add the remaining parts of the dest path
        for i = index, #dest_parts do
          relative_path = relative_path .. dest_parts[i] .. "/"
        end

        -- Remove trailing slash
        relative_path = relative_path:sub(1, -2)

        -- trim markdown header formatting
        index = string.find(selection.text, "# ")
        local display = string.sub(selection.text, index + 2)
        local link = "[" .. display .. "](" .. relative_path .. ")"

        vim.api.nvim_put({ link }, "", true, true)
      end)
      return true
    end,
  }
  require('telescope.builtin').grep_string(opts)
end

local function new_note()
  local timestamp = os.date("%Y%m%d%H%M")
  local filename = "~/dev/garden/" .. timestamp .. ".md"
  vim.cmd('e ' .. filename)
end

return {
  link_post = link_post,
  new_note = new_note,
}

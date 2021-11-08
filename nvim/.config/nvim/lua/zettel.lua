-- local pickers = require "telescope.pickers"
-- local finders = require "telescope.finders"
-- local conf = require("telescope.config").values
local actions = require "telescope.actions"
local action_state = require "telescope.actions.state"

local function link_post()
  opts = {
    prompt_title = 'Link to',
    disable_coordinates = true,
    search = '^[#]+ ',
    use_regex = true,
    attach_mappings = function(prompt_bufnr, map)
      actions.select_default:replace(function()
        actions.close(prompt_bufnr)
        local selection = action_state.get_selected_entry()

        -- trim markdown header formatting
        local index = string.find(selection.text, "# ")
        local display = string.sub(selection.text, index + 2)
        local link = "[" .. display .. "](" .. selection.filename .. ")"

        vim.api.nvim_put({ link }, "", true, true)
      end)
      return true
    end,
  }
  require('telescope.builtin').grep_string(opts)
end


return { link_post = link_post }

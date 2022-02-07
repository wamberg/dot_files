local M = {}

function M.config()
  local status_ok, lualine = pcall(require, "lualine")
  if not status_ok then
    return
  end

  local config = {
      options = {
      theme = "github",
    },
    sections = {
      lualine_c = {
        {
          "filename",
          file_status = true,
          path = 1
        }
      },
      lualine_x = {"encoding", "filetype"},
    }
  }

  lualine.setup(config)
end

return M

local BaseWindow = require('code_action_menu.windows.base_window')

local window_set_options = {
  winhighlight = 'FloatBorder:CodeActionMenuWarningMessageBorder',
}

WarningMessageWindow = BaseWindow:new()

function WarningMessageWindow:new()
  local instance = BaseWindow:new()
  setmetatable(instance, self)
  self.__index = self
  self.window_set_options = window_set_options
  return instance
end

function WarningMessageWindow:create_buffer()
  local buffer_number = vim.api.nvim_create_buf(false, true)
  local message = 'No code actions available!'

  vim.api.nvim_buf_set_lines(buffer_number, 0, 1, false, { message })
  vim.api.nvim_buf_set_option(buffer_number, 'filetype', 'code-action-menu-warning-message')

  return buffer_number
end

return WarningMessageWindow

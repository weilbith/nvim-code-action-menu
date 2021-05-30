local shared_utils = require('code_action_menu.shared_utils')
local BaseWindow = require('code_action_menu.windows.base_window')

local function create_no_actions_buffer()
  local buffer_number = vim.api.nvim_create_buf(false, true)
  local message = 'No code actions available!'

  vim.api.nvim_buf_set_lines(buffer_number, 0, 1, false, { message })
  vim.api.nvim_buf_set_option(buffer_number, 'filetype', 'code-action-menu-warning-message')

  return buffer_number
end

WarningMessageWindow = BaseWindow:new()

function WarningMessageWindow:new()
  local instance = BaseWindow:new()
  setmetatable(instance, self)
  self.__index = self
  return instance
end

function WarningMessageWindow:open()
  local buffer_number = create_no_actions_buffer()
  local buffer_width = shared_utils.get_buffer_width(buffer_number) + 1
  local buffer_height = shared_utils.get_buffer_height(buffer_number)
  local window_open_options = vim.lsp.util.make_floating_popup_options(
    buffer_width,
    buffer_height,
    { border = 'single' }
  )
  local window_number = vim.api.nvim_open_win(buffer_number, false, window_open_options)
  self.window_number = window_number
end

return WarningMessageWindow

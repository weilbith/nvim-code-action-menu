local formatting_utils = require('code_action_menu.formatting')
local BaseWindow = require('code_action_menu.windows.base_window')

local window_set_options = {
  scrolloff = 0,
  wrap = false,
  cursorline = true,
  winhighlight = 'CursorLine:CodeActionMenuSelection',
  winfixheight = true,
  winfixwidth = true,
}

local MenuWindow = BaseWindow:new()

function MenuWindow:new(all_code_actions)
  vim.validate({['all code actions'] = { all_code_actions, 'table' }})

  local instance = BaseWindow:new()
  setmetatable(instance, self)
  self.__index = self
  self.focusable = true
  self.window_set_options = window_set_options
  self.all_code_actions = all_code_actions
  return instance
end

function MenuWindow:create_buffer()
  local buffer_number = vim.api.nvim_create_buf(false, true)
  local summaries = formatting_utils.get_all_code_action_summaries(self.all_code_actions)

  vim.api.nvim_buf_set_lines(buffer_number, 0, -1, false, summaries)
  vim.api.nvim_buf_set_option(buffer_number, 'filetype', 'code-action-menu-menu')

  return buffer_number
end

function MenuWindow:get_selected_code_action()
  if self.window_number == -1 then
    error('Can not retrieve selected code action when menu is not open!')
  else
    local cursor = vim.api.nvim_win_get_cursor(self.window_number)
    local line = cursor[1]
    return self.all_code_actions[line]
  end
end

return MenuWindow

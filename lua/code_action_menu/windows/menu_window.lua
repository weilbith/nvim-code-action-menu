local shared_utils = require('code_action_menu.shared_utils')
local BaseWindow = require('code_action_menu.windows.base_window')

local function format_summary_for_action(action, index)
  vim.validate({['action to format summary for'] = { action, 'table' }})

  local formatted_index = ' [' .. index .. ']'
  local kind = '(' .. action:get_kind() .. ')'
  local disabled = action:is_disabled() and ' [disabled]' or ''
  local title = action:get_title()
  return formatted_index .. ' ' .. kind .. ' ' .. title .. disabled
end

local MenuWindow = BaseWindow:new()

function MenuWindow:new(all_actions)
  vim.validate({['all code actions'] = { all_actions, 'table' }})

  local instance = BaseWindow:new({
    focusable = true,
    window_set_options = window_set_options,
    all_actions = all_actions,
  })

  setmetatable(instance, self)
  self.__index = self
  self.buffer_name = 'CodeActionMenuMenu'
  return instance
end

function MenuWindow:create_buffer()
  local buffer_number = vim.api.nvim_create_buf(false, true)
  local buffer_content = {}

  for index, action in shared_utils.iterate_actions_ordered(self.all_actions) do
    local line = format_summary_for_action(action, index)
    table.insert(buffer_content, line)
  end

  vim.api.nvim_buf_set_lines(buffer_number, 0, -1, false, buffer_content)
  vim.api.nvim_buf_set_option(buffer_number, 'filetype', 'code-action-menu-menu')

  return buffer_number
end

function MenuWindow:get_window_configuration(buffer_number)
  vim.validate({['buffer number to create window for'] = { buffer_number, 'number' }})

  local window_position = vim.api.nvim_win_get_position(0)
  local absolute_cursor_row = window_position[1] + vim.api.nvim_call_function('winline', {})
  local absolute_cursor_column = window_position[2] + vim.api.nvim_call_function('wincol', {})
  local editor_height = vim.api.nvim_get_option('lines')
  local open_space_bottom = editor_height - absolute_cursor_row
  local menu_window_width = shared_utils.get_buffer_width(buffer_number) + 1
  local menu_window_height = shared_utils.get_buffer_height(buffer_number)
  local menu_window_row = 0
  local menu_window_column = absolute_cursor_column + 1

  if open_space_bottom > menu_window_height then
    menu_window_row = absolute_cursor_row
  else
    menu_window_row = absolute_cursor_row - menu_window_height - 2
  end

  return {
    relative = 'editor',
    row = menu_window_row,
    col = menu_window_column,
    width = menu_window_width,
    height = menu_window_height,
    focusable = self.focusable,
    style = 'minimal',
    border = 'single',
  }
end

function MenuWindow:get_selected_action()
  if self.window_number == -1 then
    error('Can not retrieve selected action when menu is not open!')
  else
    local cursor = vim.api.nvim_win_get_cursor(self.window_number)
    local line = cursor[1]
    return shared_utils.get_action_at_index_ordered(self.all_actions, line)
  end
end

return MenuWindow

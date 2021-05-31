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

function MenuWindow:new(all_actions)
  vim.validate({['all code actions'] = { all_actions, 'table' }})

  local instance = BaseWindow:new({
    focusable = true,
    window_set_options = window_set_options,
    all_actions = all_actions,
  })

  setmetatable(instance, self)
  self.__index = self
  return instance
end

function MenuWindow:create_buffer()
  local buffer_number = vim.api.nvim_create_buf(false, true)
  local buffer_content = {}

  for index, action in ipairs(self.all_actions) do
    local formatted_index = ' [' .. index .. ']'
    local line = formatted_index .. ' ' .. action:get_summary()
    table.insert(buffer_content, line)
  end

  vim.api.nvim_buf_set_lines(buffer_number, 0, -1, false, buffer_content)
  vim.api.nvim_buf_set_option(buffer_number, 'filetype', 'code-action-menu-menu')

  return buffer_number
end

function MenuWindow:get_selected_action()
  if self.window_number == -1 then
    error('Can not retrieve selected action when menu is not open!')
  else
    local cursor = vim.api.nvim_win_get_cursor(self.window_number)
    local line = cursor[1]
    return self.all_actions[line]
  end
end

return MenuWindow

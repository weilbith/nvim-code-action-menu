local formatting_utils = require('code_action_menu.formatting')

local function create_details_buffer(code_action)
  vim.validate({['code action'] = { code_action, 'table' }})

  local buffer_number = vim.api.nvim_create_buf(false, true)
  local details = formatting_utils.get_code_action_details(code_action)
  vim.api.nvim_buf_set_lines(buffer_number, 0, -1, false, details)

  -- Set the filetype after the content because the fplugin makes it unmodifiable.
  vim.api.nvim_buf_set_option(buffer_number, 'filetype', 'code-action-menu-details')

  return buffer_number
end

local function open_details_window(menu_window_number, details_window_height, buffer_number)
  vim.inspect({['menu window number'] = { menu_window_number, 'number' }})
  vim.inspect({['details window height'] = { details_window_height, 'number' }})
  vim.inspect({['details buffer number'] = { buffer_number, 'number' }})

  if menu_window_number == -1 then
    error('Can not open code action details window without a menu!')
  end

  -- Do not use window position as it is wrong at this point in time.
  local menu_window_config = vim.api.nvim_win_get_config(menu_window_number)
  local menu_window_row = menu_window_config.row[false]
  local menu_window_column = menu_window_config.col[false]
  local menu_window_height = menu_window_config.height
  local menu_window_width = menu_window_config.width
  local editor_height = vim.api.nvim_get_option('lines')
  local border_height_of_two_windows = 4
  local open_space_bottom = editor_height - menu_window_row - menu_window_height - border_height_of_two_windows
  local details_window_row = 0

  if open_space_bottom >= details_window_height then
    details_window_row = menu_window_row + border_height_of_two_windows + 1
  else
    details_window_row = menu_window_row - details_window_height - border_height_of_two_windows + 1
  end

  local window_open_options = {
    relative = 'editor',
    row = details_window_row,
    col = menu_window_column,
    width = menu_window_width,
    height = details_window_height,
    focusable = false,
    style = 'minimal',
    border = 'single'
  }

  return vim.api.nvim_open_win(buffer_number, false, window_open_options)
end


DetailsWindow = { window_number = -1 }

function DetailsWindow:new()
  local instance = {}
  setmetatable(instance, self)
  self.__index = self
  return instance
end

function DetailsWindow:open_or_update(code_action, menu_window_number)
  vim.validate({['code action'] = { code_action, 'table' }})
  vim.validate({['menu window number'] = { menu_window_number, 'number' }})

  local buffer_number = create_details_buffer(code_action)
  local buffer_height = #vim.api.nvim_buf_get_lines(buffer_number, 0, -1, false)

  if self.window_number == -1 then
    self.window_number = open_details_window(menu_window_number, buffer_height, buffer_number)
  else
    vim.api.nvim_win_set_buf(self.window_number, buffer_number)
    vim.api.nvim_win_set_height(self.window_number, buffer_height)
  end
end

function DetailsWindow:close()
  pcall(vim.api.nvim_win_close, self.window_number, true)
  self.window_number = -1
end

return DetailsWindow

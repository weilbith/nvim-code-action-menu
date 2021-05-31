local shared_utils = require('code_action_menu.shared_utils')
local BaseWindow = require('code_action_menu.windows.base_window')

DetailsWindow = BaseWindow:new()

function DetailsWindow:new(action)
  vim.validate({['details window action'] = { action, 'table' }})

  local instance = BaseWindow:new({ action = action })
  setmetatable(instance, self)
  self.__index = self
  return instance
end

function DetailsWindow:create_buffer()
  local buffer_number = vim.api.nvim_create_buf(false, true)
  local details = self.action:get_details()

  vim.api.nvim_buf_set_lines(buffer_number, 0, -1, false, details)
  vim.api.nvim_buf_set_option(buffer_number, 'filetype', 'code-action-menu-details')

  return buffer_number
end

function DetailsWindow:get_window_configuration(buffer_number, configuration_options)
  vim.validate({['buffer number to create window for'] = { buffer_number, 'number' }})
  vim.validate({['detail window configuration options'] = { configuration_options, 'table' }})
  vim.validate({['window number to dock details'] = { configuration_options.docking_window_number, 'number' }})

  if configuration_options.docking_window_number == -1 then
    error('The code action details window must be docked to another window!')
  end

  -- Do not use window position as it is wrong at this point in time.
  local docking_window_configuration = vim.api.nvim_win_get_config(configuration_options.docking_window_number)
  local docking_window_row = docking_window_configuration.row[false]
  local docking_window_column = docking_window_configuration.col[false]
  local docking_window_height = docking_window_configuration.height
  local docking_window_width = docking_window_configuration.width
  local editor_height = vim.api.nvim_get_option('lines')
  local window_border_height = 2
  local open_space_bottom = editor_height - docking_window_row - docking_window_height - window_border_height
  local details_window_height = shared_utils.get_buffer_height(buffer_number)
  local details_window_row = 0

  if open_space_bottom >= details_window_height then
    details_window_row = docking_window_row + docking_window_height + window_border_height + 1
  else
    details_window_row = docking_window_row - details_window_height - window_border_height
  end

  return {
    relative = 'editor',
    row = details_window_row,
    col = docking_window_column,
    width = docking_window_width,
    height = details_window_height,
    focusable = false,
    style = 'minimal',
    border = 'single'
  }
end

return DetailsWindow

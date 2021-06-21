local shared_utils = require('code_action_menu.shared_utils')
local BaseWindow = require('code_action_menu.windows.base_window')

DockingWindow = BaseWindow:new()

function DockingWindow:new(base_object)
  local instance = BaseWindow:new(base_object or {})
  setmetatable(instance, self)
  self.__index = self
  return instance
end

function DockingWindow:get_window_configuration(buffer_number, configuration_options)
  vim.validate({['buffer number to create window for'] = { buffer_number, 'number' }})
  vim.validate({['detail window configuration options'] = { configuration_options, 'table' }})
  vim.validate({['window number to dock on'] = { configuration_options.window_to_dock_on, 'number' }})

  if configuration_options.window_to_dock_on == -1 then
    error('Invalid window number to dock on!')
  end

  local window_border_height = 2
  -- Do not use window position as it is wrong at this point in time.
  local window_to_dock_on_configuration = vim.api.nvim_win_get_config(configuration_options.window_to_dock_on)
  local window_to_dock_on_row = window_to_dock_on_configuration.row[false]
  local window_to_dock_on_column = window_to_dock_on_configuration.col[false]
  local window_to_dock_on_height = window_to_dock_on_configuration.height + window_border_height
  local window_to_dock_on_width = window_to_dock_on_configuration.width
  local editor_height = vim.api.nvim_get_option('lines')
  local open_space_bottom = editor_height - window_to_dock_on_row - window_to_dock_on_height
  local docking_window_height = shared_utils.get_buffer_height(buffer_number)
  local docking_window_row = 0

  if open_space_bottom >= docking_window_height then
    docking_window_row = window_to_dock_on_row + window_to_dock_on_height
  else
    docking_window_row = window_to_dock_on_row - docking_window_height - 2
  end

  return {
    relative = 'editor',
    row = docking_window_row,
    col = window_to_dock_on_column,
    width = window_to_dock_on_width,
    height = docking_window_height,
    focusable = false,
    style = 'minimal',
    border = 'single'
  }
end

return DockingWindow

local M = {}
package.loaded[...] = M

local formatting_utils = require('code_action_menu.formatting')
local menu_window = require('code_action_menu.menu_window')

local code_action_details_window_number = -1

local function create_buffer(code_action)
  vim.validate({['code action'] = { code_action, 'table' }})

  local buffer_number = vim.api.nvim_create_buf(false, true)
  local details = formatting_utils.get_code_action_details(code_action)
  vim.api.nvim_buf_set_lines(buffer_number, 0, -1, false, details)

  -- Set the filetype after the content because the fplugin makes it unmodifiable.
  vim.api.nvim_buf_set_option(buffer_number, 'filetype', 'code-action-menu-details')

  return buffer_number
end

local function open_details_window(buffer_number, details_window_height)
  vim.inspect({['details buffer number'] = { buffer_number, 'number' }})
  vim.inspect({['details window height'] = { details_window_height, 'number' }})

  local menu_window_number = menu_window.code_action_menu_window_number

  if menu_window_number == -1 then
    error('Can not open code action details window without a code action menu!')
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
    details_window_row = menu_window_row - details_window_height -  border_height_of_two_windows + 1
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


-- Meant to be executed from the menu window.
local function open_or_update_code_action_details_window()
  -- TODO: change this when the loading order of the Lua modules got fixed.
  -- local selected_code_action = menu_window.get_selected_code_action_in_open_menu()
  local all_code_actions = vim.api.nvim_win_get_var(menu_window.code_action_menu_window_number, 'all_code_actions')
  local cursor = vim.api.nvim_win_get_cursor(menu_window.code_action_menu_window_number)
  local line = cursor[1]
  local selected_code_action = all_code_actions[line]
  local buffer_number = create_buffer(selected_code_action)

  if code_action_details_window_number == -1 then
    code_action_details_window_number = open_details_window(buffer_number, 5)
  else
    vim.api.nvim_win_set_buf(code_action_details_window_number, buffer_number)
  end
end

local function close_code_action_details_window()
  pcall(vim.api.nvim_win_close, code_action_details_window_number, true)
  code_action_details_window_number = -1
end

M = {
  open_or_update_code_action_details_window = open_or_update_code_action_details_window,
  close_code_action_details_window = close_code_action_details_window,
}

return M

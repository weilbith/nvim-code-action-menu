local shared_utils = require('code_action_menu.shared_utils')
local MenuWindow = require('code_action_menu.windows.menu_window')
local DetailsWindow = require('code_action_menu.windows.details_window')
local WarningMessageWindow = require('code_action_menu.windows.warning_message_window')

local menu_window_instance = nil
local details_window_instance = nil
local warning_message_window_instace = nil

local function open_code_action_menu()
  local all_actions = shared_utils.request_servers_for_actions()

  if #all_actions == 0 then
    warning_message_window_instace = WarningMessageWindow:new()
    warning_message_window_instace:open()
    vim.api.nvim_command('autocmd! CursorMoved <buffer> ++once lua require("code_action_menu").close_warning_message_window()')
  else
    menu_window_instance = MenuWindow:new(all_actions)
    menu_window_instance:open()
  end
end

local function update_action_details()
  local selected_action = menu_window_instance:get_selected_action()

  if details_window_instance == nil then
    details_window_instance = DetailsWindow:new(selected_action)
  else
    details_window_instance.action = selected_action
  end

  details_window_instance:open({ docking_window_number = menu_window_instance.window_number })
end

local function close_code_action_menu()
  details_window_instance:close()
  details_window_instance = nil
  menu_window_instance:close()
  menu_window_instance = nil
end

local function close_warning_message_window()
  warning_message_window_instace:close()
  warning_message_window_instace = nil
end

local function execute_selected_action()
  local selected_action = menu_window_instance:get_selected_action()
  close_code_action_menu() -- Close first to execute the action in the correct buffer.
  selected_action:execute()
end

local function select_line_and_execute_action(line_number)
  vim.validate({['to select menu line number'] = { line_number, 'number' }})

  vim.api.nvim_win_set_cursor(menu_window_instance.window_number, { line_number, 0 })
  execute_selected_action()
end

return {
  open_code_action_menu = open_code_action_menu,
  update_action_details = update_action_details,
  close_code_action_menu = close_code_action_menu,
  close_warning_message_window = close_warning_message_window,
  execute_selected_action = execute_selected_action,
  select_line_and_execute_action = select_line_and_execute_action,
}

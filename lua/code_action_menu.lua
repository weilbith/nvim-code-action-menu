local lsp_requests = require('code_action_menu.lsp_requests')
local MenuWindow = require('code_action_menu.windows.menu_window')
local DetailsWindow = require('code_action_menu.windows.details_window')

local menu_window_instance = nil
local details_window_instance = nil

local function open_code_action_menu()
  local all_code_actions = lsp_requests.request_code_actions()

  if all_code_actions ~= nil then
    if menu_window_instance == nil then
      menu_window_instance = MenuWindow:new()
    end

    menu_window_instance:open(all_code_actions)
  end
end

local function update_code_action_details()
  local code_action = menu_window_instance:get_selected_code_action()

  if details_window_instance == nil then
    details_window_instance = DetailsWindow:new()
  end

  details_window_instance:open_or_update(code_action, menu_window_instance.window_number)
end

local function close_code_action_menu()
  details_window_instance:close()
  details_window_instance = nil
  menu_window_instance:close()
  menu_window_instance = nil
end

local function execute_selected_code_action()
  local selected_code_action = menu_window_instance:get_selected_code_action()
  close_code_action_menu() -- Close first to execute the action in the correct buffer.
  lsp_requests.execute_code_action(selected_code_action)
end

return {
  open_code_action_menu = open_code_action_menu,
  update_code_action_details = update_code_action_details,
  execute_selected_code_action = execute_selected_code_action,
  close_code_action_menu = close_code_action_menu,
}

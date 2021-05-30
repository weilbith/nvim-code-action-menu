local lsp_requests = require('code_action_menu.lsp_requests')
local menu_window = require('code_action_menu.menu_window'):new()
local details_window = require('code_action_menu.details_window'):new()

local function open_code_action_menu()
  local all_code_actions = lsp_requests.request_code_actions()

  if all_code_actions ~= nil then
    menu_window:open(all_code_actions)
  end
end

local function execute_selected_code_action()
  local selected_code_action = menu_window:get_selected_code_action()
  menu_window:close() -- Close first to execute the action in the correct buffer.
  lsp_requests.execute_code_action(selected_code_action)
end

local function close_code_action_menu()
  details_window:close()
  menu_window:close()
end

local function update_code_action_details()
  local code_action = menu_window:get_selected_code_action()
  details_window:open_or_update(code_action, menu_window.window_number)
end

return {
  open_code_action_menu = open_code_action_menu,
  update_code_action_details = update_code_action_details,
  execute_selected_code_action = execute_selected_code_action,
  close_code_action_menu = close_code_action_menu,
}

local lsp_requests = require('code_action_menu.lsp_requests')
local menu_window = require('code_action_menu.menu_window')

local function open_code_action_menu()
  local all_code_actions = lsp_requests.request_code_actions()

  if all_code_actions ~= nil then
    menu_window.open_code_action_menu_window(all_code_actions)
  end
end

local function execute_selected_code_action()
  local selected_code_action = menu_window.get_selected_code_action_in_open_menu()
  menu_window.close_code_action_menu_window() -- Close first to execute the action in the correct buffer.
  lsp_requests.execute_code_action(selected_code_action)
end

return {
  open_code_action_menu = open_code_action_menu,
  select_code_action = select_code_action,
}

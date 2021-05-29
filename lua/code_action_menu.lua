local lsp_requests = require('code_action_menu.lsp_requests')
local menu_window = require('code_action_menu.menu_window')

local function open_code_action_menu()
  local code_actions = lsp_requests.request_code_actions()

  if code_actions ~= nil then
    menu_window.open_window(code_actions)
  end
end

return {
  open_code_action_menu = open_code_action_menu,
}

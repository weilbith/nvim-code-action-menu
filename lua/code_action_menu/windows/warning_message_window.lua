local BaseWindow = require('code_action_menu.windows.base_window')

local WarningMessageWindow = BaseWindow:new()

function WarningMessageWindow:new()
  local instance = BaseWindow:new()
  setmetatable(instance, self)
  self.__index = self
  self.filetype = 'code-action-menu-warning-message'
  return instance
end

function WarningMessageWindow:get_content()
  return { 'No code actions available!' }
end

return WarningMessageWindow

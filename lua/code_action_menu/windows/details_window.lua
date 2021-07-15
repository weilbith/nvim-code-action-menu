local StackingWindow = require('code_action_menu.windows.stacking_window')

local DetailsWindow = StackingWindow:new()

function DetailsWindow:new(action)
  vim.validate({ ['details window action'] = { action, 'table' } })

  local instance = StackingWindow:new({ action = action })
  setmetatable(instance, self)
  self.__index = self
  self.buffer_name = 'CodeActionMenuDetails'
  self.filetype = 'code-action-menu-details'
  return instance
end

function DetailsWindow:get_content()
  local title = self.action:get_title()
  local kind = self.action:get_kind()
  local name = self.action:get_name()
  local preferred = self.action:is_preferred() and 'yes' or 'no'
  local disabled = self.action:is_disabled()
      and ('yes - ' .. self.action:get_disabled_reason())
    or 'no'

  return {
    title,
    '',
    'Kind:        ' .. kind,
    'Name:        ' .. name,
    'Preferred:   ' .. preferred,
    'Disabled:    ' .. disabled,
  }
end

function DetailsWindow:set_action(action)
  vim.validate({ ['updated details window action'] = { action, 'table' } })

  self.action = action
end

return DetailsWindow

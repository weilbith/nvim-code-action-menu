local StackingWindow = require('code_action_menu.windows.stacking_window')

local function format_details_for_action(action)
  vim.validate({['action to format details for'] = { action, 'table' }})

  local title = action:get_title()
  local kind = action:get_kind()
  local name  = action:get_name()
  local preferred = action:is_preferred() and 'yes' or 'no'
  local disabled = action:is_disabled() and ('yes - ' .. action:get_disabled_reason()) or 'no'

  return {
    title,
    '',
    'Kind:        ' .. kind,
    'Name:        ' .. name,
    'Preferred:   ' .. preferred,
    'Disabled:    ' .. disabled,
  }
end

DetailsWindow = StackingWindow:new()

function DetailsWindow:new(action)
  vim.validate({['details window action'] = { action, 'table' }})

  local instance = StackingWindow:new({ action = action })
  setmetatable(instance, self)
  self.__index = self
  self.buffer_name = 'CodeActionMenuDetails'
  return instance
end

function DetailsWindow:create_buffer()
  local buffer_number = vim.api.nvim_create_buf(false, true)
  local details = format_details_for_action(self.action)

  vim.api.nvim_buf_set_lines(buffer_number, 0, -1, false, details)
  vim.api.nvim_buf_set_option(buffer_number, 'filetype', 'code-action-menu-details')

  return buffer_number
end

function DetailsWindow:set_action(action)
  vim.validate({['updated details window action'] = { action, 'table' }})

  self.action = action
end

return DetailsWindow

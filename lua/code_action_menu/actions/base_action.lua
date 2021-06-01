local BaseAction = {}

function BaseAction:new(server_data)
  vim.validate({['server data'] = { server_data, 'table' }})

  local instance = { server_data = server_data }
  setmetatable(instance, self)
  self.__index = self
  return instance
end

function BaseAction:get_title()
  return self.server_data.title or 'missing title'
end

function BaseAction:get_kind()
  return 'undefined'
end

function BaseAction:get_name()
  return 'undefined'
end

function BaseAction:get_disabled_reason()
  return 'undefined'
end

function BaseAction:is_preferred()
  return false
end

function BaseAction:is_disabled()
  return false
end

function BaseAction:get_summary()
  local kind = '(' .. self:get_kind() .. ')'
  local disabled = self:is_disabled() and ' [disabled]' or ''
  return kind .. ' ' .. self:get_title() .. disabled
end

function BaseAction:get_details()
  local preferred = self:is_preferred() and 'yes' or 'no'
  local disabled = self:is_disabled() and ('yes - ' .. self:get_disabled_reason()) or 'no'
  return {
    self.server_data.title,
    '',
    'Kind:        ' .. self:get_kind(),
    'Name:        ' .. self:get_name(),
    'Preferred:   ' .. preferred,
    'Disabled:    ' .. disabled,
  }
end

function BaseAction:execute()
  error('Base actions can not be executed, but derived classes have to implement it!')
end

return BaseAction

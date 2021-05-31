local BaseAction = {}

function BaseAction:new(server_data)
  vim.validate({['server data'] = { server_data, 'table' }})

  local instance = { server_data = server_data }
  setmetatable(instance, self)
  self.__index = self
  return instance
end

function BaseAction:get_title()
  return (self.server_data or {}).title or 'missing title'
end

function BaseAction:get_kind()
  return 'undefined' -- meant to be overwritten by derivations
end

function BaseAction:get_summary()
  local kind = '(' .. self:get_kind() .. ')'
  return kind .. ' ' .. self:get_title()
end

function BaseAction:get_details()
  -- TODO: replace mocked data
  return {
    self.server_data.title,
    '',
    'Kind:       ' .. self:get_kind(),
    'Preferred:  ' .. 'yes',
    'Fixes:      - missing import for "foo"',
    '            - can not find declaration for this stupid',
    '              what ever this is',
  }
end

function BaseAction:execute()
  error('Base actions can not be executed, but derived classes have to implement it!')
end

return BaseAction

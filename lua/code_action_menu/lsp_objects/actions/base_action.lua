local WorkspaceEdit = require(
  'code_action_menu.lsp_objects.edits.workspace_edit'
)

local BaseAction = {}

function BaseAction:new(data)
  vim.validate({ ['data'] = { data, 'table' } })
  local instance = { server_data = data[1], client_id = data[2] }
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

function BaseAction:get_workspace_edit()
  return WorkspaceEdit:new()
end

function BaseAction:execute()
  error(
    'Base actions can not be executed, but derived classes have to implement it!'
  )
end

return BaseAction

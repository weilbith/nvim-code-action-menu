local BaseAction = require('code_action_menu.actions.base_action')

local CodeAction = BaseAction:new({})

function CodeAction:new(server_data)
  local instance = BaseAction:new(server_data)
  setmetatable(instance, self)
  self.__index = self
  return instance
end

function CodeAction:is_workspace_edit()
  return self.server_data.edit ~= nil and type(self.server_data.edit) == 'table'
end

function CodeAction:is_command()
  return self.server_data.command ~= nil and type(self.server_data.command) == 'table'
end

function CodeAction:get_kind()
  if self.server_data.kind ~= nil then
    return self.server_data.kind
  elseif self:is_workspace_edit() then
    return 'workspace edit'
  elseif self:is_command() then
    return 'command'
  else
    return 'unknown'
  end
end

function CodeAction:execute()
  if self:is_workspace_edit() then
    vim.lsp.util.apply_workspace_edit(self.server_data.edit)
  elseif self:is_command() then
    vim.lsp.buf.execute_command(self.server_data.command)
  else
    error('Failed to execute code action of unknown kind!')
  end
end

return CodeAction

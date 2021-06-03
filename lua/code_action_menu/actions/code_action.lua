local BaseAction = require('code_action_menu.actions.base_action')

local CodeAction = BaseAction:new({})

function CodeAction:new(server_data)
  local instance = BaseAction:new(server_data)
  setmetatable(instance, self)
  self.__index = self
  return instance
end

function CodeAction:is_workspace_edit()
  local edit = self.server_data.edit
  return type(edit) == 'table'
end

function CodeAction:is_command()
  local command = self.server_data.command
  return type(command) == 'table'
end

function CodeAction:get_kind()
  if self.server_data.kind ~= nil then
    local kind = self.server_data.kind
    return kind == '' and 'undefined' or kind
  elseif self:is_workspace_edit() then
    return 'workspace edit'
  elseif self:is_command() then
    return 'command'
  else
    return 'undefined'
  end
end

function CodeAction:get_name()
  if self:is_command() then
    return self.server_data.command.command
  else
    return 'undefined'
  end
end

function CodeAction:is_preferred()
  return self.server_data.isPreferred or false
end

function CodeAction:is_disabled()
  return self.server_data.disabled ~= nil
end

function CodeAction:get_disabled_reason()
  return self.server_data.disabled.reason
end

function CodeAction:execute()
  if self:is_workspace_edit() then
    vim.lsp.util.apply_workspace_edit(self.server_data.edit)
  elseif self:is_command() then
    vim.lsp.buf.execute_command(self.server_data.command)
  else
    vim.api.nvim_notify('Failed to execute code action of unknown kind!', vim.log.levels.ERROR, {})
  end
end

return CodeAction

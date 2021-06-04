local BaseAction = require('code_action_menu.lsp_objects.actions.base_action')
local TextDocumentEdit = require('code_action_menu.lsp_objects.edits.text_document_edit')
local TextEdit = require('code_action_menu.lsp_objects.edits.text_edit')

local CodeAction = BaseAction:new({})

function CodeAction:new(server_data)
  local instance = BaseAction:new(server_data)
  setmetatable(instance, self)
  self.__index = self

  if server_data.diagnostics ~= nil then
    print(vim.inspect(server_data.diagnostics))
  end

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
  if type(self.server_data.kind) == 'string' and #self.server_data.kind > 0 then
    return self.server_data.kind
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

function CodeAction:get_edits()
  local all_edits = {}

  if self:is_workspace_edit() then
    for _, data in ipairs(self.server_data.edit.documentChanges or {}) do
      local text_document_edit = TextDocumentEdit:new(data)
      table.insert(all_edits, text_document_edit)
    end

    for uri, payload in ipairs(self.server_data.edit.changes or {}) do
      local text_edit = TextEdit:new(uri, payload)
      table.insert(all_edits, text_edit)
    end
  end

  return all_edits
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

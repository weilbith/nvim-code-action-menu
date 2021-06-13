local BaseAction = require('code_action_menu.lsp_objects.actions.base_action')
local TextDocumentEdit = require('code_action_menu.lsp_objects.edits.text_document_edit')
local WorkspaceEdit = require('code_action_menu.lsp_objects.edits.workspace_edit')

local Command = BaseAction:new({})

function Command:new(server_data)
  local instance = BaseAction:new(server_data)
  setmetatable(instance, self)
  self.__index = self
  return instance
end

function Command:get_kind()
  return 'command'
end

function Command:get_name()
  return self.server_data.command or 'undefined'
end

-- Though commands do nowdays actually not include edits anymore, some LSP
-- servers still use them like that. This can be detected by inspecting the
-- commands arguments.
function Command:get_workspace_edit()
  local workspace_edit = WorkspaceEdit:new()

  for _, argument in ipairs(self.server_data.arguments or {}) do
    for _, data in ipairs(argument.documentChanges or {}) do
      local text_document_edit = TextDocumentEdit:new(data)
      workspace_edit:add_text_document_edit(text_document_edit)
    end
  end

  return workspace_edit
end

function Command:execute()
  vim.lsp.buf.execute_command(self.server_data)
end

return Command

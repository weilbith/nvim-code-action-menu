local BaseEdit = require('code_action_menu.lsp_objects.edits.base_edit')

local TextDocumentEdit = BaseEdit:new({})

function TextDocumentEdit:new(server_data)
  vim.validate({['server data to parse as text document edit'] = { server_data, 'table' }})
  vim.validate({['text document property'] = { server_data.textDocument, 'table' }})
  vim.validate({['edits property'] = { server_data.edits, 'table' }})

  local instance = BaseEdit:new({ server_data = server_data })
  setmetatable(instance, self)
  self.__index = self
  return instance
end

function TextDocumentEdit:get_included_uris()
  return { self.server_data.textDocument.uri }
end

return TextDocumentEdit

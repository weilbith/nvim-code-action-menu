local WorkspaceEdit = {}

function WorkspaceEdit:new()
  local instance = { uri_to_text_document_edit = {} }
  setmetatable(instance, self)
  self.__index = self
  return instance
end

function WorkspaceEdit:get_all_text_document_edits()
  local all_text_document_edits = {}
    
  for _, text_document_edit in pairs(self.uri_to_text_document_edit) do
    table.insert(all_text_document_edits, text_document_edit)
  end

  return all_text_document_edits
end

function WorkspaceEdit:add_text_document_edit(text_document_edit)
  vim.validate({['to add text document edit'] = { text_document_edit, 'table' }})

  local uri = text_document_edit.uri

  if self.uri_to_text_document_edit[uri] ~= nil then
    self.uri_to_text_document_edit[uri].add_edits(text_document_edit.edits)
  else
    self.uri_to_text_document_edit[uri] = text_document_edit
  end
end

return WorkspaceEdit

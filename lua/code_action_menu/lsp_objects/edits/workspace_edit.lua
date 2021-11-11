local WorkspaceEdit = {}

function WorkspaceEdit:new()
  local instance = { all_text_document_edits = {} }
  setmetatable(instance, self)
  self.__index = self
  return instance
end

function WorkspaceEdit:add_text_document_edit(text_document_edit)
  vim.validate({
    ['to add text document edit'] = { text_document_edit, 'table' },
  })

  for _, existing_text_document_edit in ipairs(self.all_text_document_edits) do
    if existing_text_document_edit.uri == text_document_edit.uri then
      existing_text_document_edit:merge_text_document_edit_for_same_uri(
        text_document_edit
      )
      return
    end
  end

  table.insert(self.all_text_document_edits, text_document_edit)
end

return WorkspaceEdit

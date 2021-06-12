local TextDocumentEdit = {}

function TextDocumentEdit:new(uri, edits)
  vim.validate({['text document uri'] = { uri, 'string' }})
  vim.validate({['text document edits'] = { edits, 'table' }})

  local instance = { uri = uri, edits = edits }
  setmetatable(instance, self)
  self.__index = self
  return instance
end

function TextDocumentEdit:add_edits(edits)
  vim.validate({['text document edits'] = { edits, 'table' }})

  vim.list_extend(self.edits, edits)
end

function TextDocumentEdit:get_document_path()
  local absolute_path = vim.uri_to_fname(self.uri)
  local current_working_directory = vim.api.nvim_call_function('getcwd', {})
  local home_directory = os.getenv("HOME")

  if absolute_path:find(current_working_directory, 1, true) then
    return absolute_path:sub(current_working_directory:len() + 2)
  elseif absolute_path:find(home_directory, 1, true) then
    return absolute_path:sub(home_directory:len() + 2)
  else
    return absolute_path
  end
end

return TextDocumentEdit

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

function TextDocumentEdit:get_number_of_added_lines()
  local added_lines = {}
  local number_of_added_lines = 0

  for _, edit in ipairs(self.edits) do
    local startLine = edit.range.start.line
    local endLine = edit.range['end'].line
    local text = edit.newText

    -- TODO: This includes lines where new text gets inserted.
    if startLine == endLine and #text > 0 and added_lines[startLine] == nil then
      added_lines[startLine] = true
      number_of_added_lines_in_edit = select(2, text:gsub('\n', '\n'))
      number_of_added_lines = number_of_added_lines + number_of_added_lines_in_edit
    end
  end

  return number_of_added_lines
end

function TextDocumentEdit:get_number_of_deleted_lines()
  local deleted_lines = {}
  local number_of_deleted_lines = 0

  for _, edit in ipairs(self.edits) do
    local startLine = edit.range.start.line
    local endLine = edit.range['end'].line
    local text = edit.newText

    -- TODO: This includes lines where text gets deleted inside.
    if #text == 0 then
      for line = startLine, endLine do
        if deleted_lines[line] == nil then
          deleted_lines[line] = true
          number_of_deleted_lines = number_of_deleted_lines + 1
        end
      end
    end
  end

  return number_of_deleted_lines
end

return TextDocumentEdit

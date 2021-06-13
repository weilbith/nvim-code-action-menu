local TextDocumentEditStatusEnum = require('code_action_menu.enumerations.text_document_edit_status_enum')

local TextDocumentEdit = {}

function TextDocumentEdit:new(server_data)
  vim.validate({['text document server data'] = { server_data, 'table' }})

  local uri = server_data.uri or server_data.newUri or server_data.textDocument.uri
  local edits = server_data.edits or {}
  local kind = server_data.kind
  local status = (
    kind == 'create' and TextDocumentEditStatusEnum.CREATED or
    kind == 'rename' and TextDocumentEditStatusEnum.RENAMED or
    kind == 'delete' and TextDocumentEditStatusEnum.DELETED or
    TextDocumentEditStatusEnum.CHANGED
  )

  local instance = {
    uri = uri ,
    edits = edits,
    status = status,
  }

  setmetatable(instance, self)
  self.__index = self
  return instance
end

function TextDocumentEdit:merge_text_document_edit_for_same_uri(text_document_edit)
  vim.validate({['text document edit to merge'] = { text_document_edit, 'table' }})

  if text_document_edit.uri ~= self.uri then
    error("Can not merge to TextDocumentEdits for different URIs!")
  end

  vim.list_extend(self.edits, text_document_edit.edits or {})

  if text_document_edit.status ~= TextDocumentEditStatusEnum.CHANGED then
    self.status = text_document_edit.status
  end
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

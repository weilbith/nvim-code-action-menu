local TextDocumentEditStatusEnum = require('code_action_menu.enumerations.text_document_edit_status_enum')

local function get_line_count_of_text(text)
  vim.validate({['text to get line count for'] = { text, 'string' }})

  local new_line_count = select(2, text:gsub('\n', '\n'))
  local line_count = new_line_count + 1

  if text:sub(-1) == '\n' then
    line_count = line_count - 1
  end

  return line_count
end

-- This assumes that all edits do only insert new text
local function get_line_count_of_all_edits(all_edits)
  vim.validate({['edits to count'] = { all_edits, 'table' }})
  
  local line_count = 0

  for _, edit in ipairs(all_edits) do
    line_count = line_count + get_line_count_of_text(edit.newText)
  end
  
  return line_count
end

local function get_added_line_count_of_all_edits(all_edits)
  vim.validate({['edits to count'] = { all_edits, 'table' }})

  local added_line_count = 0

  for _, edit in ipairs(all_edits) do
    local added_line_count_of_edit = get_line_count_of_text(edit.newText)
    added_line_count = added_line_count + added_line_count_of_edit
  end

  return added_line_count
end

local function get_deleted_line_count_of_all_edits(all_edits)
  vim.validate({['edits to count'] = { all_edits, 'table' }})

  local deleted_line_count = 0

  for _, edit in ipairs(all_edits) do
    local startLine = edit.range.start.line
    local startColumn = edit.range.start.character
    local endLine = edit.range['end'].line
    local endColumn = edit.range['end'].character
    local text = edit.newText

    -- This makes sure it isn't a pure new text insertion outside the scope
    -- of just one line.
    if not (startLine == endLine and startColumn == endColumn and text:sub(-1) == '\n') then
      local deleted_line_count_of_edit = endLine - startLine + 1
      deleted_line_count = deleted_line_count + deleted_line_count_of_edit
    end
  end

  return deleted_line_count
end

local function get_line_count_of_file(uri)
  vim.validate({['uri to get line count for'] = { uri, 'string' }})

  local path = vim.uri_to_fname(uri)
  local handle = vim.loop.fs_open(path, "r", 438)
  local statistics = vim.loop.fs_fstat(handle)
  local text = vim.loop.fs_read(handle, statistics.size)
  vim.loop.fs_close(handle)
  return get_line_count_of_text(text)
end

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

-- Takes the `git diff --numstat` as model. This means it only acts on full
-- lines. As result a changed line counts as one added and one deleted at the
-- same time.
-- This "algorithm" is very limited and assumes that the language server its
-- edits are efficient. This means that there are not multiple edits which act
-- on the same or intersecting text ranges.
-- 
-- Returns tuple of (added_line_count, deleted_line_count)
function TextDocumentEdit:get_line_number_statistics()
  if self.status == TextDocumentEditStatusEnum.CREATED then
    local added_line_count = get_line_count_of_all_edits(self.edits)
    return { added_line_count, 0 }

  elseif self.status == TextDocumentEditStatusEnum.DELETED then
    local deleted_line_count = get_line_count_of_file(self.uri)
    return { 0, deleted_line_count }

  else
    local added_line_count = get_added_line_count_of_all_edits(self.edits)
    local deleted_line_count = get_deleted_line_count_of_all_edits(self.edits)
    return { added_line_count, deleted_line_count }
  end
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

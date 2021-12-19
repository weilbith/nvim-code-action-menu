local TextDocumentEditStatusEnum = require(
  'code_action_menu.enumerations.text_document_edit_status_enum'
)

local inaccessible_content_placeholder = '<inaccessible content>'

local function uri_has_custom_scheme(uri)
  return uri:sub(1, 4) ~= 'file'
end

local function read_line_from_file(file_name, row)
  local file_descriptor = vim.loop.fs_open(file_name, 'r', 438)

  if not file_descriptor then
    return inaccessible_content_placeholder
  end

  local file_statistics = vim.loop.fs_fstat(file_descriptor)
  local file_content = vim.loop.fs_read(
    file_descriptor,
    file_statistics.size,
    0
  )
  vim.loop.fs_close(file_descriptor)

  local line_number = 0

  for line in string.gmatch(file_content, '([^\n]*)\n?') do
    if line_number == row then
      return line
    end
    line_number = line_number + 1
  end

  return inaccessible_content_placeholder
end

local function get_line(uri, row)
  if uri_has_custom_scheme(uri) then
    local buffer_number = vim.uri_to_bufnr(uri)
    vim.fn.bufload(buffer_number)
  end

  local file_name = vim.uri_to_fname(uri)

  if vim.fn.bufloaded(file_name) == 1 then
    local buffer_number = vim.fn.bufnr(file_name, false)
    local lines = vim.api.nvim_buf_get_lines(buffer_number, row, row + 1, false)
    return lines[1] or inaccessible_content_placeholder
  end

  return read_line_from_file(file_name, row)
end

local function get_line_count_of_text(text)
  vim.validate({ ['text to get line count for'] = { text, 'string' } })

  local new_line_count = select(2, text:gsub('\n', '\n'))
  local line_count = new_line_count + 1

  if text:sub(-1) == '\n' then
    line_count = line_count - 1
  end

  return line_count
end

local function get_added_line_count_of_all_edits(all_edits)
  vim.validate({ ['edits to count'] = { all_edits, 'table' } })

  local added_line_count = 0

  for _, edit in ipairs(all_edits) do
    local added_line_count_of_edit = get_line_count_of_text(edit.newText)
    added_line_count = added_line_count + added_line_count_of_edit
  end

  return added_line_count
end

local function get_deleted_line_count_of_all_edits(all_edits)
  vim.validate({ ['edits to count'] = { all_edits, 'table' } })

  local deleted_line_count = 0

  for _, edit in ipairs(all_edits) do
    local startLine = edit.range.start.line
    local startColumn = edit.range.start.character
    local endLine = edit.range['end'].line
    local endColumn = edit.range['end'].character
    local text = edit.newText

    -- This makes sure it isn't a pure new text insertion outside the scope
    -- of just one line.
    if
      not (
        startLine == endLine
        and startColumn == endColumn
        and text:sub(-1) == '\n'
      )
    then
      local deleted_line_count_of_edit = endLine - startLine + 1
      deleted_line_count = deleted_line_count + deleted_line_count_of_edit
    end
  end

  return deleted_line_count
end

local function get_line_count_of_file(uri)
  vim.validate({ ['uri to get line count for'] = { uri, 'string' } })

  local path = vim.uri_to_fname(uri)
  local handle = vim.loop.fs_open(path, 'r', 438)
  local statistics = vim.loop.fs_fstat(handle)
  local text = vim.loop.fs_read(handle, statistics.size)
  vim.loop.fs_close(handle)
  return get_line_count_of_text(text)
end

local function get_list_of_added_lines_in_edit(uri, edit)
  local added_lines = {}

  for line in vim.gsplit(edit.newText, '\n', true) do
    table.insert(added_lines, line)
  end

  local first_original_complete_line = get_line(uri, edit.range.start.line)
    or ''

  local text_before_changes = first_original_complete_line:sub(
    0,
    edit.range.start.character
  )
  added_lines[1] = text_before_changes .. added_lines[1]

  local last_original_complete_line = get_line(uri, edit.range['end'].line)
    or ''

  if #last_original_complete_line > edit.range['end'].character then
    local text_after_changes = last_original_complete_line:sub(
      edit.range['end'].character + 1
    )
    added_lines[#added_lines] = added_lines[#added_lines] .. text_after_changes
  end

  local line_index = edit.range.start.line

  for index = 1, #added_lines, 1 do
    added_lines[index] = line_index .. ' ' .. added_lines[index]
    line_index = line_index + 1
  end

  return added_lines
end

local function get_list_of_original_lines(uri, start_line, end_line)
  local original_lines = {}

  for line_index = start_line, end_line, 1 do
    local line = get_line(uri, line_index)

    if line ~= nil then
      line = line_index .. ' ' .. line
      table.insert(original_lines, line)
    end
  end

  return original_lines
end

local TextDocumentEdit = {}

function TextDocumentEdit:new(server_data)
  vim.validate({ ['text document server data'] = { server_data, 'table' } })

  local uri = server_data.uri
    or server_data.newUri
    or server_data.textDocument.uri
  local edits = server_data.edits or {}
  local kind = server_data.kind
  local status = (
      kind == 'create' and TextDocumentEditStatusEnum.CREATED
      or kind == 'rename' and TextDocumentEditStatusEnum.RENAMED
      or kind == 'delete' and TextDocumentEditStatusEnum.DELETED
      or TextDocumentEditStatusEnum.CHANGED
    )

  local instance = {
    uri = uri,
    edits = edits,
    status = status,
  }

  setmetatable(instance, self)
  self.__index = self
  return instance
end

function TextDocumentEdit:merge_text_document_edit_for_same_uri(
  text_document_edit
)
  vim.validate({
    ['text document edit to merge'] = { text_document_edit, 'table' },
  })

  if text_document_edit.uri ~= self.uri then
    error('Can not merge to TextDocumentEdits for different URIs!')
  end

  vim.list_extend(self.edits, text_document_edit.edits or {})

  if text_document_edit.status ~= TextDocumentEditStatusEnum.CHANGED then
    self.status = text_document_edit.status
  end
end

function TextDocumentEdit:get_document_path()
  local absolute_path = vim.uri_to_fname(self.uri)
  local current_working_directory = vim.api.nvim_call_function('getcwd', {})
  local home_directory = os.getenv('HOME')

  if absolute_path:find(current_working_directory, 1, true) then
    return absolute_path:sub(current_working_directory:len() + 2)
  elseif
    home_directory ~= nil and absolute_path:find(home_directory, 1, true)
  then
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
-- Returns table with the key `added` and `deleted` with numbers as values
function TextDocumentEdit:get_line_number_statistics()
  if self.status == TextDocumentEditStatusEnum.CREATED then
    local added_line_count = get_added_line_count_of_all_edits(self.edits)
    return { added = added_line_count, deleted = 0 }
  elseif self.status == TextDocumentEditStatusEnum.DELETED then
    local deleted_line_count = get_line_count_of_file(self.uri)
    return { added = 0, deleted = deleted_line_count }
  else
    local added_line_count = get_added_line_count_of_all_edits(self.edits)
    local deleted_line_count = get_deleted_line_count_of_all_edits(self.edits)
    return { added = added_line_count, deleted = deleted_line_count }
  end
end

function TextDocumentEdit:get_diff_lines()
  local all_diffs = {}
  local context_line_count = 1

  for _, edit in ipairs(self.edits) do
    local start_line = edit.range.start.line
    local end_line = edit.range['end'].line
    local context_before_lines = get_list_of_original_lines(
      self.uri,
      start_line - context_line_count,
      start_line - 1
    )
    local deleted_lines = get_list_of_original_lines(
      self.uri,
      start_line,
      end_line
    )
    local added_lines = get_list_of_added_lines_in_edit(self.uri, edit)
    local context_after_lines = get_list_of_original_lines(
      self.uri,
      end_line + 1,
      end_line + context_line_count
    )

    table.insert(all_diffs, {
      context_before = context_before_lines,
      deleted = deleted_lines,
      added = added_lines,
      context_after = context_after_lines,
    })
  end

  return all_diffs
end

return TextDocumentEdit

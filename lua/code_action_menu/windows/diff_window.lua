local StackingWindow = require('code_action_menu.windows.stacking_window')
local TextDocumentEditStatusEnum = require('code_action_menu.enumerations.text_document_edit_status_enum')

local function get_text_document_edit_status_icon(status)
  return (
    status == TextDocumentEditStatusEnum.CREATED and '*' or
    status == TextDocumentEditStatusEnum.CHANGED and '~' or
    status == TextDocumentEditStatusEnum.RENAMED and '>' or
    status == TextDocumentEditStatusEnum.DELETED and '!' or
    error("Can not get icon unknown TextDocumentEdit status: '" .. status .. "'")
  )
end

local function get_summary_line_formatted(text_document_edit)
  local status_icon = get_text_document_edit_status_icon(text_document_edit.status)
  local file_path = text_document_edit:get_document_path()
  local line_number_statistics = text_document_edit:get_line_number_statistics()
  local changes = '(+' .. line_number_statistics.added .. ' -' .. line_number_statistics.deleted .. ')'
  return status_icon .. file_path .. ' ' .. changes
end

local function get_diff_lines_formatted(text_document_edit)
  local diff_lines = {}

  for _, changed_lines in ipairs(text_document_edit:get_diff_lines()) do
    for _, context_line in ipairs(changed_lines.context_before) do
      table.insert(diff_lines, ' ' .. context_line)
    end

    for _, deleted_line in ipairs(changed_lines.deleted) do
      table.insert(diff_lines, '-' .. deleted_line)
    end

    for _, added_line in ipairs(changed_lines.added) do
      table.insert(diff_lines, '+' .. added_line)
    end

    for _, context_line in ipairs(changed_lines.context_after) do
      table.insert(diff_lines, ' ' .. context_line)
    end
  end

  return diff_lines
end

local function get_diff_square_counts(text_document_edit)
  local line_number_statistics = text_document_edit:get_line_number_statistics()
  local total_changed_lines = line_number_statistics.added + line_number_statistics.deleted
  local modulu_five = total_changed_lines % 5
  local total_changed_lines_round_to_five = total_changed_lines + (modulu_five > 0 and 5 - modulu_five or 0)
  local lines_per_square = total_changed_lines_round_to_five / 5
  local squares_for_added_lines = math.floor(line_number_statistics.added / lines_per_square)
  local squares_for_deleted_lines = math.floor(line_number_statistics.deleted / lines_per_square)

  if line_number_statistics.added > 0 and squares_for_added_lines == 0 then
    squares_for_added_lines = 1
  end

  if line_number_statistics.deleted > 0 and squares_for_deleted_lines == 0 then
    squares_for_deleted_lines = 1
  end

  local squares_for_neutral_fill = 5 - squares_for_added_lines - squares_for_deleted_lines

  return {
    added = squares_for_added_lines,
    deleted = squares_for_deleted_lines,
    neutral = squares_for_neutral_fill,
  }
end

-- We need to use virtual text here as coloring the squares differently simply
-- is not possible with traditional syntax highlighting. At least not without
-- much pita.
local function add_colored_diff_square_as_virtual_text(buffer_number, action)
  local workspace_edit = action:get_workspace_edit()

  for index, text_document_edit in ipairs(workspace_edit.all_text_document_edits) do
    local square_counts = get_diff_square_counts(text_document_edit)
    local chunks = {}

    if square_counts.added > 0 then
      table.insert(chunks, { string.rep('■', square_counts.added), 'CodeActionMenuDetailsAddedSquares' })
    end

    if square_counts.deleted > 0 then
      table.insert(chunks, { string.rep('■', square_counts.deleted), 'CodeActionMenuDetailsDeletedSquares' })
    end

    if square_counts.neutral > 0 then
      table.insert(chunks, { string.rep('■', square_counts.neutral), 'CodeActionMenuDetailsNeutralSquares' })
    end

    vim.api.nvim_buf_set_virtual_text(buffer_number, -1, index -1 , chunks, {} )
  end
end

DiffWindow = StackingWindow:new()

function DiffWindow:new(action)
  vim.validate({['diff window action'] = { action, 'table' }})

  local instance = StackingWindow:new({ action = action })
  setmetatable(instance, self)
  self.__index = self
  self.buffer_name = 'CodeActionMenuDiff'
  self.filetype = 'code-action-menu-diff'
  return instance
end

function DiffWindow:get_content()
  local content = {}
  local workspace_edit = self.action:get_workspace_edit()

  for _, text_document_edit in ipairs(workspace_edit.all_text_document_edits) do
    local summary_line = get_summary_line_formatted(text_document_edit)
    table.insert(content, summary_line)

    local diff_lines = get_diff_lines_formatted(text_document_edit)
    vim.list_extend(content, diff_lines)
  end

  return content
  -- add_colored_diff_square_as_virtual_text(buffer_number, self.action)
end

function DiffWindow:set_action(action)
  vim.validate({['updated diff window action'] = { action, 'table' }})

  self.action = action
end

return DiffWindow

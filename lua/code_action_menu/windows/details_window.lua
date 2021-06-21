local DockingWindow = require('code_action_menu.windows.docking_window')
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

local function get_action_workspace_edit_summary_lines(action)
  local workspace_edit = action:get_workspace_edit()
  local all_summary_lines = {}

  for _, text_document_edit in ipairs(workspace_edit.all_text_document_edits) do
    local status_icon = get_text_document_edit_status_icon(text_document_edit.status)
    local file_path = text_document_edit:get_document_path()
    local line_number_statistics = text_document_edit:get_line_number_statistics()
    local changes = '(+' .. line_number_statistics[1] .. ' -' .. line_number_statistics[2] .. ')'
    local summary_line = status_icon .. file_path .. ' ' .. changes
    table.insert(all_summary_lines, summary_line)
  end

  return all_summary_lines
end

local function format_details_for_action(action)
  vim.validate({['action to format details for'] = { action, 'table' }})

  local title = action:get_title()
  local kind = action:get_kind()
  local name  = action:get_name()
  local preferred = action:is_preferred() and 'yes' or 'no'
  local disabled = action:is_disabled() and ('yes - ' .. action:get_disabled_reason()) or 'no'

  local details = {
    title,
    '',
    'Kind:        ' .. kind,
    'Name:        ' .. name,
    'Preferred:   ' .. preferred,
    'Disabled:    ' .. disabled,
  }

  local changing_summary_lines = get_action_workspace_edit_summary_lines(action)

  if #changing_summary_lines ~= 0 then
    table.insert(details, 'Changes:     ' .. changing_summary_lines[1])
  end

  for index = 2, #changing_summary_lines do
    table.insert(details, '             ' .. changing_summary_lines[index])
  end

  return details
end

DetailsWindow = DockingWindow:new()

function DetailsWindow:new(action)
  vim.validate({['details window action'] = { action, 'table' }})

  local instance = DockingWindow:new({ action = action })
  setmetatable(instance, self)
  self.__index = self
  self.buffer_name = 'CodeActionMenuDetails'
  return instance
end

function DetailsWindow:create_buffer()
  local buffer_number = vim.api.nvim_create_buf(false, true)
  local details = format_details_for_action(self.action)

  vim.api.nvim_buf_set_lines(buffer_number, 0, -1, false, details)
  vim.api.nvim_buf_set_option(buffer_number, 'filetype', 'code-action-menu-details')

  return buffer_number
end

function DetailsWindow:set_action(action)
  vim.validate({['updated details window action'] = { action, 'table' }})

  self.action = action
end

return DetailsWindow

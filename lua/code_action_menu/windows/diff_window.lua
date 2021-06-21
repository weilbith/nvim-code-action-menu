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

local function format_diff_for_action(action)
  local workspace_edit = action:get_workspace_edit()
  local diff = {}

  for _, text_document_edit in ipairs(workspace_edit.all_text_document_edits) do
    local status_icon = get_text_document_edit_status_icon(text_document_edit.status)
    local file_path = text_document_edit:get_document_path()
    local line_number_statistics = text_document_edit:get_line_number_statistics()
    local changes = '(+' .. line_number_statistics[1] .. ' -' .. line_number_statistics[2] .. ')'
    local line = status_icon .. file_path .. ' ' .. changes
    table.insert(diff, line)
  end

  return diff
end

DiffWindow = DockingWindow:new()

function DiffWindow:new(action)
  vim.validate({['diff window action'] = { action, 'table' }})

  local instance = DockingWindow:new({ action = action })
  setmetatable(instance, self)
  self.__index = self
  self.buffer_name = 'CodeActionMenuDiff'
  return instance
end

function DiffWindow:create_buffer()
  local buffer_number = vim.api.nvim_create_buf(false, true)
  local diff = format_diff_for_action(self.action)

  vim.api.nvim_buf_set_lines(buffer_number, 0, -1, false, diff)
  vim.api.nvim_buf_set_option(buffer_number, 'filetype', 'code-action-menu-diff')

  return buffer_number
end

function DiffWindow:set_action(action)
  vim.validate({['updated diff window action'] = { action, 'table' }})

  self.action = action
end

return DiffWindow

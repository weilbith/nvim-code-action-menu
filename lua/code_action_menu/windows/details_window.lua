local shared_utils = require('code_action_menu.shared_utils')
local BaseWindow = require('code_action_menu.windows.base_window')
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
    local number_of_added_lines = text_document_edit:get_number_of_added_lines()
    local number_of_deleted_lines = text_document_edit:get_number_of_deleted_lines()
    local summary_line = status_icon .. file_path .. ' (+' .. number_of_added_lines .. ' -' ..number_of_deleted_lines .. ')'
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

DetailsWindow = BaseWindow:new()

function DetailsWindow:new(action)
  vim.validate({['details window action'] = { action, 'table' }})

  local instance = BaseWindow:new({ action = action })
  setmetatable(instance, self)
  self.__index = self
  return instance
end

function DetailsWindow:create_buffer()
  local buffer_number = vim.api.nvim_create_buf(false, true)
  local details = format_details_for_action(self.action)

  vim.api.nvim_buf_set_lines(buffer_number, 0, -1, false, details)
  vim.api.nvim_buf_set_option(buffer_number, 'filetype', 'code-action-menu-details')

  return buffer_number
end

function DetailsWindow:get_window_configuration(buffer_number, configuration_options)
  vim.validate({['buffer number to create window for'] = { buffer_number, 'number' }})
  vim.validate({['detail window configuration options'] = { configuration_options, 'table' }})
  vim.validate({['window number to dock details'] = { configuration_options.docking_window_number, 'number' }})

  if configuration_options.docking_window_number == -1 then
    error('The code action details window must be docked to another window!')
  end

  local window_border_height = 2
  -- Do not use window position as it is wrong at this point in time.
  local docking_window_configuration = vim.api.nvim_win_get_config(configuration_options.docking_window_number)
  local docking_window_row = docking_window_configuration.row[false]
  local docking_window_column = docking_window_configuration.col[false]
  local docking_window_height = docking_window_configuration.height + window_border_height
  local docking_window_width = docking_window_configuration.width
  local editor_height = vim.api.nvim_get_option('lines')
  local open_space_bottom = editor_height - docking_window_row - docking_window_height
  local details_window_height = shared_utils.get_buffer_height(buffer_number)
  local details_window_row = 0

  if open_space_bottom >= details_window_height then
    details_window_row = docking_window_row + docking_window_height
  else
    details_window_row = docking_window_row - details_window_height - 2
  end

  return {
    relative = 'editor',
    row = details_window_row,
    col = docking_window_column,
    width = docking_window_width,
    height = details_window_height,
    focusable = false,
    style = 'minimal',
    border = 'single'
  }
end

function DetailsWindow:set_action(action)
  vim.validate({['updated details window action'] = { action, 'table' }})

  self.action = action
end

return DetailsWindow

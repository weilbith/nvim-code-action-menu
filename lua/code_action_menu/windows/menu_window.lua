local formatting_utils = require('code_action_menu.formatting')
local shared_utils = require('code_action_menu.shared_utils')
local BaseWindow = require('code_action_menu.windows.base_window')

local window_set_options = {
  scrolloff = 0,
  wrap = false,
  cursorline = true,
  winhighlight = 'CursorLine:CodeActionMenuSelection',
  winfixheight = true,
  winfixwidth = true,
}

local function create_menu_buffer(all_code_actions)
  vim.validate({['all code actions'] = { all_code_actions, 'table' }})

  local buffer_number = vim.api.nvim_create_buf(false, true)
  local summaries = formatting_utils.get_all_code_action_summaries(all_code_actions)
  vim.api.nvim_buf_set_lines(buffer_number, 0, 1, false, summaries)

  -- Set the filetype after the content because the fplugin makes it unmodifiable.
  vim.api.nvim_buf_set_option(buffer_number, 'filetype', 'code-action-menu-menu')

  return buffer_number
end


local MenuWindow = BaseWindow:new()

function MenuWindow:new(all_code_actions)
  vim.validate({['all code actions'] = { all_code_actions, 'table' }})

  local instance = BaseWindow:new()
  setmetatable(instance, self)
  self.__index = self
  self.all_code_actions = all_code_actions
  return instance
end

function MenuWindow:open()
  local buffer_number = create_menu_buffer(self.all_code_actions)
  local buffer_width = shared_utils.get_buffer_width(buffer_number) + 1
  local buffer_height = shared_utils.get_buffer_height(buffer_number)
  local window_open_options = vim.lsp.util.make_floating_popup_options(
    buffer_width,
    buffer_height,
    { border = 'single' }
  )
  local window_number = vim.api.nvim_open_win(buffer_number, true, window_open_options)
  shared_utils.set_window_options(window_number, window_set_options)
  self.window_number = window_number
end

function MenuWindow:get_selected_code_action()
  if self.window_number == -1 then
    error('Can not retrieve selected code action when menu is not open!')
  else
    local cursor = vim.api.nvim_win_get_cursor(self.window_number)
    local line = cursor[1]
    return self.all_code_actions[line]
  end
end

return MenuWindow

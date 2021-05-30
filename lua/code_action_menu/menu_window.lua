local M = {}
package.loaded[...] = M

local formatting_utils = require('code_action_menu.formatting')
local lsp_requests = require('code_action_menu.lsp_requests')
local details_window = require('code_action_menu.details_window')

-- The major purpose of this variable is to give other parts of the code access to it.
-- Alternative would include some awkward searching through all windows.
-- Though as it is there, it gets used at some more places.
-- In case the variable gets out of sync, it gets fixed the next time a window gets opened.
local code_action_menu_window_number = -1

local function create_buffer(all_code_actions)
  vim.validate({['all code actions'] = { all_code_actions, 'table' }})

  local buffer_number = vim.api.nvim_create_buf(false, true)
  local summaries = formatting_utils.get_all_code_action_summaries(all_code_actions)
  vim.api.nvim_buf_set_lines(buffer_number, 0, 1, false, summaries)

  -- Set the filetype after the content because the fplugin makes it unmodifiable.
  vim.api.nvim_buf_set_option(buffer_number, 'filetype', 'code-action-menu-menu')

  return buffer_number
end

local function get_buffer_width(buffer_number)
  local buffer_lines = vim.api.nvim_buf_get_lines(buffer_number, 0, -1, false)
  local longest_line = ''

  for _, line in ipairs(buffer_lines) do
    if #line > #longest_line then
      longest_line = line
    end
  end

  return #longest_line
end

local function set_window_options(window_number, window_options)
  vim.validate({['preview window number'] = { window_number, 'number' }})
  vim.validate({['preview window options'] = { window_options, 'table' }})

  for name, value in pairs(window_options) do
    vim.api.nvim_win_set_option(window_number, name, value)
  end
end

local function open_code_action_menu_window(all_code_actions)
  vim.validate({['all code actions'] = { all_code_actions, 'table' }})

  local buffer_number = create_buffer(all_code_actions)
  local buffer_width = get_buffer_width(buffer_number) + 1
  local window_open_options = vim.lsp.util.make_floating_popup_options(
    buffer_width,
    #all_code_actions,
    { border = 'single' }
  )
  local window_set_options = {
    scrolloff = 0,
    wrap = false,
    cursorline = true,
    winhighlight = 'CursorLine:CodeActionMenuSelection',
    winfixheight = true,
    winfixwidth = true,
  }

  local window_number = vim.api.nvim_open_win(buffer_number, true, window_open_options)
  vim.api.nvim_win_set_var(window_number, 'all_code_actions', all_code_actions)
  set_window_options(window_number, window_set_options)
  code_action_menu_window_number = window_number
end

local function close_code_action_menu_window()
  details_window.close_code_action_details_window()
  pcall(vim.api.nvim_win_close, code_action_menu_window_number, true)
  code_action_menu_window_number = -1
end

local function get_selected_code_action_in_open_menu()
  if code_action_menu_window_number == -1 then
    error('Can not retrieve selected code action as no menu is open!')
  else
    local all_code_actions = vim.api.nvim_win_get_var(code_action_menu_window_number, 'all_code_actions')
    local cursor = vim.api.nvim_win_get_cursor(code_action_menu_window_number)
    local line = cursor[1]
    return all_code_actions[line]
  end
end

M = {
  code_action_menu_window_number = code_action_menu_window_number,
  open_code_action_menu_window = open_code_action_menu_window,
  get_selected_code_action_in_open_menu = get_selected_code_action_in_open_menu,
  close_code_action_menu_window = close_code_action_menu_window,
}

return M

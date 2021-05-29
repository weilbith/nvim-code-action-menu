local formatting_utils = require('code_action_menu.formatting')
local lsp_requests = require('code_action_menu.lsp_requests')

local function create_buffer(code_actions)
  vim.validate({['code actions'] = { code_actions, 'table' }})

  local buffer_number = vim.api.nvim_create_buf(false, true)
  local summaries = formatting_utils.get_code_action_summaries(code_actions)
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

local function open_window(code_actions)
  vim.validate({['code actions'] = { code_actions, 'table' }})

  local buffer_number = create_buffer(code_actions)
  local buffer_width = get_buffer_width(buffer_number) + 1
  local window_open_options = vim.lsp.util.make_floating_popup_options(
    buffer_width,
    #code_actions,
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
  vim.api.nvim_buf_set_var(buffer_number, 'code_actions', code_actions)
  set_window_options(window_number, window_set_options)
end

-- Meant to be execute within the menu window.
local function select_code_action()
  local cursor = vim.api.nvim_win_get_cursor(0)
  local line = cursor[1]
  local code_actions = vim.api.nvim_buf_get_var(0, 'code_actions')
  local selected_action = code_actions[line]
  vim.api.nvim_win_close(0, true) -- Close first to execute the action in the correct buffer.
  lsp_requests.execute_code_action(selected_action)
end

return {
  open_window = open_window,
  select_code_action = select_code_action,
}

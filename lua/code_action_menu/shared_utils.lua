local BaseAction = require('code_action_menu.actions.base_action')
local Command = require('code_action_menu.actions.command')
local CodeAction = require('code_action_menu.actions.code_action')

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

local function get_buffer_height(buffer_number)
  local buffer_lines = vim.api.nvim_buf_get_lines(buffer_number, 0, -1, false)
  return #buffer_lines
end

local function set_window_options(window_number, window_options)
  vim.validate({['preview window number'] = { window_number, 'number' }})
  vim.validate({['preview window options'] = { window_options, 'table' }})

  for name, value in pairs(window_options) do
    vim.api.nvim_win_set_option(window_number, name, value)
  end
end

local function request_servers_for_actions(use_range)
  vim.validate({['request action for range'] = { use_range, 'boolean', true }})

  local line_diagnostics = vim.lsp.diagnostic.get_line_diagnostics()
  local parameters = use_range and vim.lsp.util.make_given_range_params() or vim.lsp.util.make_range_params()
  parameters.context = { diagnostics = line_diagnostics }
  local all_responses = vim.lsp.buf_request_sync(0, 'textDocument/codeAction', parameters) or {}
  local all_actions = {}

  for _, client_response in ipairs(all_responses) do
    for _, data in ipairs(client_response.result) do
      local action = nil

      if type(data.edit) == 'table' or type(data.command) == 'table' then
        action = CodeAction:new(data)
      else
        action = Command:new(data)
      end

      table.insert(all_actions, action)
    end
  end

  return all_actions
end

return {
  get_buffer_width = get_buffer_width,
  get_buffer_height = get_buffer_height,
  set_window_options = set_window_options,
  request_servers_for_actions = request_servers_for_actions,
}

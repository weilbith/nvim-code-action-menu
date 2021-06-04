local Command = require('code_action_menu.lsp_objects.actions.command')
local CodeAction = require('code_action_menu.lsp_objects.actions.code_action')

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
    for _, data in ipairs(client_response.result or {}) do
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

local function order_actions(action_table, key_a, key_b)
  local action_a = action_table[key_a]
  local action_b = action_table[key_b]

  if action_b:is_preferred() and not action_a:is_preferred() then
    return false
  elseif action_a:is_disabled() and not action_b:is_disabled() then
    return false
  else
    -- Ordering function needs to return `true` at some point for every element.
    return key_a < key_b
  end
end

local function get_ordered_action_table_keys(action_table)
  vim.validate({['action table to sort'] = { action_table, 'table' }})
  local keys = {}

  for key in pairs(action_table) do
    local index = #keys + 1
    keys[index] = key
  end

  table.sort(keys, function(key_a, key_b)
    return order_actions(action_table, key_a, key_b)
  end)

  return keys
end

-- Put preferred actions at start, disabled at end
local function iterate_actions_ordered(action_table)
  vim.validate({['actions to sort'] = { action_table, 'table' }})

  local keys = get_ordered_action_table_keys(action_table)
  local index = 0

  return function()
    index = index + 1

    if keys[index] then
      return index, action_table[keys[index]]
    end
  end
end

local function get_action_at_index_ordered(action_table, index)
  vim.validate({['actions to sort'] = { action_table, 'table' }})

  local keys = get_ordered_action_table_keys(action_table)
  local key_for_index = keys[index]
  return action_table[key_for_index]
end

local function uri_to_relative_path(uri)
  vim.validate({['uri to get relative path for '] = { uri, 'string' }})

  local absolute_path = vim.uri_to_fname(uri)
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

return {
  get_buffer_width = get_buffer_width,
  get_buffer_height = get_buffer_height,
  set_window_options = set_window_options,
  request_servers_for_actions = request_servers_for_actions,
  iterate_actions_ordered = iterate_actions_ordered,
  get_action_at_index_ordered = get_action_at_index_ordered,
  uri_to_relative_path = uri_to_relative_path,
}

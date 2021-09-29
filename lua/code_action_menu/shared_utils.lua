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

local function is_buffer_empty(buffer_number)
  local buffer_lines = vim.api.nvim_buf_get_lines(buffer_number, 0, -1, false)
  return #buffer_lines == 0 or (#buffer_lines == 1 and #buffer_lines[1] == 0)
end

local function resolve_code_action(client_id, server_data)
  vim.validate({ ['action to resolve'] = { server_data, 'table' } })

  local client = vim.lsp.get_client_by_id(client_id)

  if client ~= nil then
    return client.request_sync('codeAction/resolve', server_data, 0, 0)
  else
    vim.api.nvim_notify(
      'Failed to resolve action for unknown client!',
      vim.log.levels.WARN,
      {}
    )
    return nil
  end
end

local function parse_server_data_as_action(server_data)
  if type(server_data) == 'table' and type(server_data.command) == 'string' then
    return Command:new(server_data)
  elseif
    type(server_data) == 'table'
    and (
      type(server_data.edit) == 'table'
      or type(server_data.command) == 'table'
    )
  then
    return CodeAction:new(server_data)
  else
    vim.api.nvim_notify(
      'Failed to parse unknown code action or command data structure! Skipped.',
      vim.log.levels.WARN,
      {}
    )
    return nil
  end
end

local function parse_code_action_responses(all_responses)
  local all_actions = {}

  for client_id, client_response in pairs(all_responses) do
    for _, server_data in ipairs(client_response.result or {}) do
      if type(server_data) == 'table' and server_data.data ~= nil then
        server_data = resolve_code_action(client_id, server_data)
      end

      local action = parse_server_data_as_action(server_data)

      if action ~= nil then
        table.insert(all_actions, action)
      end
    end
  end

  return all_actions
end

local function request_servers_for_actions(use_range)
  vim.validate({ ['request action for range'] = { use_range, 'boolean', true } })

  local line_diagnostics = vim.lsp.diagnostic.get_line_diagnostics()
  local parameters = use_range and vim.lsp.util.make_given_range_params()
    or vim.lsp.util.make_range_params()

  parameters.context = { diagnostics = line_diagnostics }

  local all_responses = vim.lsp.buf_request_sync(
    0,
    'textDocument/codeAction',
    parameters
  ) or {}

  return parse_code_action_responses(all_responses)
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
  vim.validate({ ['action table to sort'] = { action_table, 'table' } })
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
  vim.validate({ ['actions to sort'] = { action_table, 'table' } })

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
  vim.validate({ ['actions to sort'] = { action_table, 'table' } })

  local keys = get_ordered_action_table_keys(action_table)
  local key_for_index = keys[index]
  return action_table[key_for_index]
end

return {
  get_buffer_width = get_buffer_width,
  get_buffer_height = get_buffer_height,
  is_buffer_empty = is_buffer_empty,
  request_servers_for_actions = request_servers_for_actions,
  iterate_actions_ordered = iterate_actions_ordered,
  get_action_at_index_ordered = get_action_at_index_ordered,
}

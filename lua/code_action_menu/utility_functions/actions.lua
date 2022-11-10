local Command = require('code_action_menu.lsp_objects.actions.command')
local CodeAction = require('code_action_menu.lsp_objects.actions.code_action')

local function unpack_result_and_error(server_data, client_id)
  local client = vim.lsp.get_client_by_id(client_id)
  local result = nil
  local error = nil

  if server_data == nil then
    error = 'Server for client \'' .. client.name .. '\' not yet ready!'
  elseif type(server_data) == 'table' and server_data.err ~= nil then
    error = 'Server of client \'' .. client.name .. '\' returned error: '

    if type(server_data.err) == 'string' then
      error = error .. server_data.err
    elseif
      type(server_data.err) == 'table'
      and type(server_data.err.message) == 'string'
    then
      error = error .. server_data.err.message
    else
      error = error .. 'unknown error - failed to parse response'
    end
  elseif type(server_data) == 'table' and server_data.result then
    result = server_data.result
  else
    result = server_data
  end

  return result, error
end

local function resolve_code_action(client_id, code_action_object)
  local client = vim.lsp.get_client_by_id(client_id)
  local response = client.request_sync('codeAction/resolve', code_action_object)
  local action_object, error = unpack_result_and_error(response, client_id)

  if error then
    vim.api.nvim_notify(error, vim.log.levels.WARN, {})
  end

  return action_object
end

local function parse_object_as_action(code_action_object)
  if
    type(code_action_object) == 'table'
    and type(code_action_object.command) == 'string'
  then
    return Command:new(code_action_object)
  elseif
    type(code_action_object) == 'table'
    and (
      type(code_action_object.edit) == 'table'
      or type(code_action_object.command) == 'table'
    )
  then
    return CodeAction:new(code_action_object)
  else
    local error =
      'Failed to parse unknown code action or command data structure! Skipped.'
    vim.api.nvim_notify(error, vim.log.levels.WARN, {})
    return nil
  end
end

local function parse_action_data_objects(client_id, all_code_action_objects)
  local all_actions = {}

  for _, code_action_object in ipairs(all_code_action_objects) do
    if
      type(code_action_object) == 'table' and code_action_object.data ~= nil
    then
      code_action_object = resolve_code_action(client_id, code_action_object)
    end

    local action = parse_object_as_action(code_action_object)

    if action ~= nil then
      table.insert(all_actions, action)
    end
  end

  return all_actions
end

local function request_actions_from_server(client_id, parameters)
  local client = vim.lsp.get_client_by_id(client_id)

  if not client.supports_method('textDocument/codeAction') then
    return {}
  end

  local response = client.request_sync('textDocument/codeAction', parameters)
  local action_objects, error = unpack_result_and_error(response, client_id)

  if error then
    vim.api.nvim_notify(error, vim.log.levels.WARN, {})
  end

  return action_objects or {}
end

local function get_range_request_parameters()
  local selection_start = {}
  selection_start[1], selection_start[2] = unpack(vim.fn.getpos('v'), 2, 3)
  -- NOTE: getpos's column is 1-based, and we need 0-based
  selection_start[2] = selection_start[2] - 1

  local selection_end = vim.api.nvim_win_get_cursor(0)

  -- NOTE: handle "reverse" selection (the cursor is at the start of the
  -- selection, not the end)
  -- Flip based on lines
  if selection_start[1] > selection_end[1] then
    local temp_selection_end = selection_end
    selection_end = selection_start
    selection_start = temp_selection_end
  end

  -- Flip based on columns
  if selection_start[2] > selection_end[2] then
    local temp_selection_end = selection_end[2]
    selection_end[2] = selection_start[2]
    selection_start[2] = temp_selection_end
  end

  return vim.lsp.util.make_given_range_params(selection_start, selection_end)
end

local function request_actions_from_all_servers(options)
  vim.validate({
    ['options is table'] = { options, 't', true },
  })

  options = options or {}
  local request_parameters =
    options.use_range
    and get_range_request_parameters()
    or vim.lsp.util.make_range_params()

  local line_diagnostics = vim.lsp.diagnostic.get_line_diagnostics()
  request_parameters.context = {
    diagnostics = options.diagnostics or line_diagnostics
  }

  local all_clients = vim.lsp.buf_get_clients()
  local all_actions = {}

  for _, client in pairs(all_clients) do
    local action_data_objects = request_actions_from_server(
      client.id,
      request_parameters
    )
    local actions = parse_action_data_objects(client.id, action_data_objects)
    vim.list_extend(all_actions, actions)
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
  request_actions_from_all_servers = request_actions_from_all_servers,
  iterate_actions_ordered = iterate_actions_ordered,
  get_action_at_index_ordered = get_action_at_index_ordered,
}

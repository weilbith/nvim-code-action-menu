local function request_code_actions()
  local line_diagnostics = vim.lsp.diagnostic.get_line_diagnostics()
  local parameters = vim.lsp.util.make_range_params()
  parameters.context = { diagnostics = line_diagnostics }
  local all_responses = vim.lsp.buf_request_sync(0, 'textDocument/codeAction', parameters) or {}
  local all_code_actions = {}

  for _, client_response in ipairs(all_responses) do
    for _, code_action in ipairs(client_response.result) do
      table.insert(all_code_actions, code_action)
    end
  end

  return all_code_actions
end

local function execute_code_action(code_action)
  vim.validate({['code action to execute'] = { code_action, 'table' }})

  if code_action.edit or type(code_action.command) == "table" then
    if code_action.edit then
      vim.lsp.util.apply_workspace_edit(code_action.edit)
    end
    if type(code_action.command) == "table" then
      vim.lsp.buf.execute_command(code_action.command)
    end
  else
    vim.lsp.buf.execute_command(code_action)
  end
end

return {
  request_code_actions = request_code_actions,
  execute_code_action = execute_code_action,
}

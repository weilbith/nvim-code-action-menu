local function get_code_action_summaries(code_actions)
  vim.validate({['code actions'] = { code_actions, 'table' }})

  local all_summaries = {}

  for index, code_action in ipairs(code_actions) do
    -- Add a leading space for the cursor.
    local summary = ' [' .. index .. '] ' .. code_action.title
    table.insert(all_summaries, summary)
  end

  return all_summaries
end

return {
  get_code_action_summaries = get_code_action_summaries,
}

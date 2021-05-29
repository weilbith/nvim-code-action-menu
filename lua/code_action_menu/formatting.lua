local function get_code_action_summaries(code_actions)
  vim.validate({['code actions'] = { code_actions, 'table' }})

  local all_summaries = {}

  for index, code_action in ipairs(code_actions) do
    local preferred = (code_action.isPreferred or false) and '*' or ' '
    local key = '[' .. index .. ']'
    local kind = '(' .. (code_action.kind or 'empty') .. ')'
    local title = code_action.title
    local summary = preferred .. key .. ' ' .. kind .. ' ' .. title
    table.insert(all_summaries, summary)
  end

  return all_summaries
end

return {
  get_code_action_summaries = get_code_action_summaries,
}

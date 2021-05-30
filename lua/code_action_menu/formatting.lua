local function get_all_code_action_summaries(all_code_actions)
  vim.validate({['all code actions'] = { all_code_actions, 'table' }})

  local all_summaries = {}

  for index, code_action in ipairs(all_code_actions) do
    local preferred = (code_action.isPreferred or false) and '*' or ' '
    local key = '[' .. index .. ']'
    local kind = '(' .. (code_action.kind or 'empty') .. ')'
    local title = code_action.title
    local summary = preferred .. key .. ' ' .. kind .. ' ' .. title
    table.insert(all_summaries, summary)
  end

  return all_summaries
end

local function get_code_action_details(code_action)
  vim.validate({['code action'] = { code_action, 'table' }})

  return { code_action.title }
end

return {
  get_all_code_action_summaries = get_all_code_action_summaries,
  get_code_action_details = get_code_action_details,
}

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

return {
  get_buffer_width = get_buffer_width,
  set_window_options = set_window_options,
}

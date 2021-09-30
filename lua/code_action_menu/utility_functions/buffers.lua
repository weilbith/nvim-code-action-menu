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

return {
  get_buffer_width = get_buffer_width,
  get_buffer_height = get_buffer_height,
  is_buffer_empty = is_buffer_empty,
}

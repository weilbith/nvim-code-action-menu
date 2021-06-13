local shared_utils = require('code_action_menu.shared_utils')

local BaseWindow = {
  window_number = -1,
  focusable = false,
  buffer_name = 'CodeActionMenuBase',
}

function BaseWindow:new(base_object)
  local instance = base_object or {}
  setmetatable(instance, self)
  self.__index = self
  return instance
end

function BaseWindow:create_buffer()
  return vim.api.nvim_create_buf(false, true)
end

function BaseWindow:get_window_configuration(buffer_number, _)
  vim.validate({['buffer number to create window for'] = { buffer_number, 'number' }})

  local buffer_width = shared_utils.get_buffer_width(buffer_number) + 1
  local buffer_height = shared_utils.get_buffer_height(buffer_number)
  return vim.lsp.util.make_floating_popup_options(
    buffer_width,
    buffer_height,
    { border = 'single' }
  )
end

function BaseWindow:open(window_configuration_options)
  vim.validate({['window configuration options'] = { window_configuration_options, 'table', true }})

  local buffer_number = self:create_buffer()
  local window_configuration = self:get_window_configuration(buffer_number, window_configuration_options)

  if self.window_number == -1 then
    self.window_number = vim.api.nvim_open_win(buffer_number, self.focusable, window_configuration)
    vim.api.nvim_command('doautocmd User CodeActionMenuWindowOpened')
  else
    vim.api.nvim_win_set_buf(self.window_number, buffer_number)
    vim.api.nvim_win_set_height(self.window_number, window_configuration.height)
  end

  vim.api.nvim_buf_set_name(buffer_number, self.buffer_name)
end

function BaseWindow:close()
  pcall(vim.api.nvim_win_close, self.window_number, true)
  self.window_number = -1
end

return BaseWindow

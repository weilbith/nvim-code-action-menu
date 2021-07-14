local shared_utils = require('code_action_menu.shared_utils')

local BaseWindow = {
  window_number = -1,
  window_options = nil,
  buffer_number = -1,
  buffer_name = 'CodeActionMenuBase',
  focusable = false,
  filetype = '',
}

function BaseWindow:new(base_object)
  local instance = base_object or {}
  setmetatable(instance, self)
  self.__index = self
  return instance
end

function BaseWindow:get_content()
  return {}
end

function BaseWindow:update_buffer_content()
  local content = self:get_content()

  if #content == 0 then
    self:close() -- This window might be already open and should be closed then.
  else
    -- Unset and set the filtype option removes temporally th read-only property
    vim.api.nvim_buf_set_option(self.buffer_number, 'filetype', '')
    vim.api.nvim_buf_set_lines(self.buffer_number, 0, -1, false, content)
    vim.api.nvim_buf_set_option(self.buffer_number, 'filetype', self.filetype)
  end
end

function BaseWindow:create_buffer()
  self.buffer_number = vim.api.nvim_create_buf(false, true)
  vim.api.nvim_buf_set_name(self.buffer_number, self.buffer_name)
  vim.api.nvim_buf_set_option(self.buffer_number, 'filetype', self.filetype)
end

function BaseWindow:get_window_configuration()
  local buffer_width = shared_utils.get_buffer_width(self.buffer_number) + 1
  local buffer_height = shared_utils.get_buffer_height(self.buffer_number)
  return vim.lsp.util.make_floating_popup_options(
    buffer_width,
    buffer_height,
    { border = 'single' }
  )
end

function BaseWindow:open(window_configuration_options)
  vim.validate({['window configuration options'] = { window_configuration_options, 'table', true }})

  if self.buffer_number == -1 then
    self:create_buffer()
  end

  self:update_buffer_content()

  local window_configuration = self:get_window_configuration(window_configuration_options)

  if self.window_number == -1 then
    self.window_number = vim.api.nvim_open_win(self.buffer_number, self.focusable, window_configuration)
    self.window_options = vim.api.nvim_win_get_config(self.window_number)
    vim.api.nvim_command('doautocmd User CodeActionMenuWindowOpened')
  end

  vim.api.nvim_win_set_height(self.window_number, window_configuration.height)
end

function BaseWindow:get_option(name)
  if self.window_options == nil then
    return nil
  else
    local option = self.window_options[name]

    -- Special treatment to get absolute positions. Ugly but...
    if name == 'row' or name == 'col' then
      return option[false]
    else
      return option
    end
  end
end

function BaseWindow:close()
  pcall(vim.api.nvim_win_close, self.window_number, true)
  self.window_number = -1
end

return BaseWindow

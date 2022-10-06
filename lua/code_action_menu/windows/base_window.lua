local buffer_utils = require('code_action_menu.utility_functions.buffers')

local BaseWindow = {
  window_number = -1,
  window_options = nil,
  buffer_number = -1,
  focusable = false,
  filetype = '',
  namespace_id = vim.api.nvim_create_namespace('code_action_menu'),
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

function BaseWindow:update_virtual_text()
  return
end

function BaseWindow:update_buffer_content()
  vim.api.nvim_buf_clear_namespace(self.buffer_number, self.namespace_id, 0, -1)

  local content = vim.tbl_map(
    function(v) return v:gsub("\n"," ") end,
    self:get_content()
  )

  -- Unset and set the filtype option removes temporally th read-only property
  vim.api.nvim_buf_set_option(self.buffer_number, 'filetype', '')
  vim.api.nvim_buf_set_lines(self.buffer_number, 0, -1, false, content)
  vim.api.nvim_buf_set_option(self.buffer_number, 'filetype', self.filetype)

  self:update_virtual_text()
end

function BaseWindow:create_buffer()
  self.buffer_number = vim.api.nvim_create_buf(false, true)
  vim.api.nvim_buf_set_option(self.buffer_number, 'filetype', self.filetype)
end

function BaseWindow:get_window_configuration(_)
  local buffer_width = buffer_utils.get_buffer_width(self.buffer_number) + 1
  local buffer_height = buffer_utils.get_buffer_height(self.buffer_number)
  return vim.lsp.util.make_floating_popup_options(buffer_width, buffer_height, {
    border = vim.g.code_action_menu_window_border or 'single',
  })
end

function BaseWindow:open(window_configuration_options)
  vim.validate({
    ['window configuration options'] = {
      window_configuration_options,
      'table',
      true,
    },
  })

  if self.buffer_number == -1 then
    self:create_buffer()
  end

  self:update_buffer_content()

  if buffer_utils.is_buffer_empty(self.buffer_number) then
    self:delete_buffer()
    self:close()
    return
  end

  local window_configuration = self:get_window_configuration(
    window_configuration_options
  )

  if self.window_number == -1 then
    self.window_number = vim.api.nvim_open_win(
      self.buffer_number,
      self.focusable,
      window_configuration
    )
    self.window_options = vim.api.nvim_win_get_config(self.window_number)
    vim.api.nvim_command('doautocmd User CodeActionMenuWindowOpened')
  else
    vim.api.nvim_win_set_config(self.window_number, window_configuration)
  end

  self:after_opened()
end

function BaseWindow:after_opened()
  return
end

function BaseWindow:set_window_width(width)
  pcall(vim.api.nvim_win_set_width, self.window_number, width)
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

function BaseWindow:delete_buffer()
  pcall(vim.api.nvim_buf_delete, self.buffer_number, { force = true })
  self.buffer_number = -1
end

function BaseWindow:close()
  self:delete_buffer()
  pcall(vim.api.nvim_win_close, self.window_number, true)
  self.window_number = -1
end

return BaseWindow

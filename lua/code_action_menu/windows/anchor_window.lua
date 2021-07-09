local BaseWindow = require('code_action_menu.windows.base_window')

local AnchorWindow = BaseWindow:new()

-- The anchor window is just a reference to an already existing window that is
-- used as an anchor for a window stack. Thereby it can't be opened, nor closed.
-- In fact it is just used to read data and still implement the window class.
-- It will reference the window currently active when getting created.
function AnchorWindow:new()
  -- These calls only work for the current window, therefore calculate them now
  -- and save for later.
  local window_number = vim.api.nvim_call_function('win_getid', {})
  local window_position = vim.api.nvim_win_get_position(window_number)
  local cursor_row = vim.api.nvim_call_function('winline', {})
  local cursor_column = vim.api.nvim_call_function('wincol', {})

  local instance = BaseWindow:new({ is_anchor = true })
  setmetatable(instance, self)
  self.__index = self
  self.window_number = window_number
  self.window_options = {
    row = { [false] = window_position[1] + cursor_row },
    col = { [false] = window_position[2] + cursor_column },
    height = 0,
    width = 0,
    zindex = nil,
  }
  return instance
end

-- Prevent it to get opened by code. It is not necesary to "block" the other
-- functions like `create_buffer` as well as they are just called from here
-- usually.
function AnchorWindow:open()
  return
end

-- Prevent it to get opened by code.
function AnchorWindow:close()
  return
end

return AnchorWindow

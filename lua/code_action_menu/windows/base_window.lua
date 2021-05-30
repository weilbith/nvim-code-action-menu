local BaseWindow = { window_number = -1 }

function BaseWindow:new()
  local instance = {}
  setmetatable(instance, self)
  self.__index = self
  return instance
end

function BaseWindow:close()
  pcall(vim.api.nvim_win_close, self.window_number, true)
  self.window_number = -1
end

return BaseWindow

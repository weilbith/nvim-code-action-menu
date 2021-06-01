local BaseAction = require('code_action_menu.actions.base_action')

local Command = BaseAction:new({})

function Command:new(server_data)
  local instance = BaseAction:new(server_data)
  setmetatable(instance, self)
  self.__index = self
  return instance
end

function Command:get_kind()
  return 'command'
end

function Command:get_name()
  return self.server_data.command
end

function Command:execute()
  vim.lsp.buf.execute_command(self.server_data)
end

return Command

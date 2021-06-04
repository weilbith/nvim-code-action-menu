local BaseEdit = require('code_action_menu.lsp_objects.edits.base_edit')

local TextEdit = BaseEdit:new({})

function TextEdit:new(uri, payload)
  vim.validate({['uri of text edit'] = { uri, 'string' }})
  vim.validate({['payload of text edit'] = { payload, 'table' }})

  local instance = BaseEdit:new({ uri = uri, payload = payload })
  setmetatable(instance, self)
  self.__index = self
  return instance
end

function TextEdit:get_included_uris()
  return { self.uri }
end

return TextEdit

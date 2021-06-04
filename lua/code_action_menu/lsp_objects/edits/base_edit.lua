local BaseEdit = {}

function BaseEdit:new(base_object)
  local instance = base_object or {}
  setmetatable(instance, self)
  self.__index = self
  return instance
end

function BaseEdit:get_included_uris()
  return {}
end

return BaseEdit

local function makeEnum()
  return {
    CREATED = 'created',
    CHANGED = 'changed',
    RENAMED = 'renamed',
    DELETED = 'deleted',
  }
end

return makeEnum()

local shared_utils = require('code_action_menu.shared_utils')
local BaseWindow = require('code_action_menu.windows.base_window')
local WindowStackDirectionEnum = require('code_action_menu.enumerations.window_stack_direction_enum')

local function decide_for_direction(window)
  local editor_height = vim.api.nvim_get_option('lines')
  local free_space_top = window:get_option('row') - 1
  local free_space_bottom = editor_height - window:get_option('row') - window:get_option('height')

  -- We don't know how big the stack will grow. Therefore take the direction
  -- with more space left and hope it is enough in most cases.
  return free_space_top > free_space_bottom and WindowStackDirectionEnum.UPWARDS or WindowStackDirectionEnum.DOWNWARDS
end

local function get_stack_direction(window_stack)
  if #window_stack == 1 then
    return decide_for_direction(window_stack[1])
  end

  local direction = nil

  for index = 1, #window_stack - 1 do
    local row_current = window_stack[index]:get_option('row')
    local row_successor = window_stack[index + 1]:get_option('row')
    local new_direction = row_current > row_successor and WindowStackDirectionEnum.UPWARDS or WindowStackDirectionEnum.DOWNWARDS

    if direction == nil then
      direction = new_direction
    elseif direction ~= nil and direction ~= new_direction then
      error('Window stack is not sorted correctly!')
    end
  end

  return direction
end

StackingWindow = BaseWindow:new()

function StackingWindow:new(base_object)
  local instance = BaseWindow:new(base_object)
  setmetatable(instance, self)
  self.__index = self
  return instance
end

-- The window stack is a list of window class instances. Their order is
-- important as they specify in which direction the stack is growing. Each new
-- stacking window will be docked either on top or below the last window in
-- the stack.
function StackingWindow:get_window_configuration(buffer_number, window_configuration_options)
  vim.validate({['buffer number to create window for'] = { buffer_number, 'number' }})
  vim.validate({['window configuration options'] = { window_configuration_options, 'table' }})
  vim.validate({['window stack'] = { window_configuration_options.window_stack, 'table' }})

  local window_stack = window_configuration_options.window_stack
  local last_window = window_stack[#window_stack]
  local stack_direction = get_stack_direction(window_stack)
  local border_height = 2

  local window_height = shared_utils.get_buffer_height(buffer_number)
  local window_width = last_window:get_option('width')
  local window_column = last_window:get_option('col')
  local window_row = 0

  if stack_direction == WindowStackDirectionEnum.UPWARDS then
    window_row = last_window:get_option('row') - window_height - border_height
  elseif stack_direction == WindowStackDirectionEnum.DOWNWARDS then
    window_row = last_window:get_option('row') + last_window:get_option('height') + border_height
  end

  return {
    relative = 'editor',
    row = window_row,
    col = window_column,
    width = window_width,
    height = window_height,
    focusable = false,
    style = 'minimal',
    border = 'single'
  }
end

return StackingWindow

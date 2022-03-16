local buffer_utils = require('code_action_menu.utility_functions.buffers')
local BaseWindow = require('code_action_menu.windows.base_window')
local WindowStackDirectionEnum = require(
  'code_action_menu.enumerations.window_stack_direction_enum'
)

local function decide_for_direction(anchor_window)
  local editor_height = vim.api.nvim_get_option('lines')
  local anchor_window_row = anchor_window:get_option('row')
  local free_space_top = anchor_window_row - 1
  local free_space_bottom = editor_height - anchor_window_row

  -- We don't know how big the stack will grow. Therefore take the direction
  -- with more space left and hope it is enough in most cases.
  return free_space_top > free_space_bottom and WindowStackDirectionEnum.UPWARDS
    or WindowStackDirectionEnum.DOWNWARDS
end

local function get_stack_direction(window_stack)
  if #window_stack == 1 then
    return decide_for_direction(window_stack[1])
  end

  local direction = nil

  for index = 1, #window_stack - 1 do
    local current_row = window_stack[index]:get_option('row')
    local successor_row = window_stack[index + 1]:get_option('row')
    local new_direction = current_row > successor_row
        and WindowStackDirectionEnum.UPWARDS
      or WindowStackDirectionEnum.DOWNWARDS

    if direction == nil then
      direction = new_direction
    elseif direction ~= nil and direction ~= new_direction then
      error('Window stack is not sorted correctly!')
    end
  end

  return direction
end

local StackingWindow = BaseWindow:new()

function StackingWindow:new(base_object)
  local instance = BaseWindow:new(base_object)
  setmetatable(instance, self)
  self.__index = self
  self.window_stack = {}
  return instance
end

-- The window stack is a list of window class instances. Their order is
-- important as they specify in which direction the stack is growing. Each new
-- stacking window will be docked either on top or below the last window in
-- the stack.
function StackingWindow:get_window_configuration(window_configuration_options)
  vim.validate({
    ['buffer number to create window for'] = { self.buffer_number, 'number' },
  })
  vim.validate({
    ['window configuration options'] = {
      window_configuration_options,
      'table',
    },
  })
  vim.validate({
    ['window stack'] = { window_configuration_options.window_stack, 'table' },
  })
  vim.validate({
    ['use buffer width'] = {
      window_configuration_options.user_buffer_width,
      'boolean',
      true,
    },
  })

  self.window_stack = window_configuration_options.window_stack
  local last_window = self.window_stack[#self.window_stack]
  local stack_direction = get_stack_direction(self.window_stack)
  -- This makes the simplification to assume that all floating windows have a border...
  local border_height = last_window:get_option('zindex') and 2 or 0

  local window_height = buffer_utils.get_buffer_height(self.buffer_number)
  local window_width = buffer_utils.get_buffer_width(self.buffer_number) + 1
  local window_column = last_window:get_option('col')
  local window_row = 0

  if stack_direction == WindowStackDirectionEnum.UPWARDS then
    window_row = last_window:get_option('row') - window_height - border_height
    window_row = window_row - (last_window.is_anchor and 3 or 0)
  elseif stack_direction == WindowStackDirectionEnum.DOWNWARDS then
    window_row = last_window:get_option('row')
      + last_window:get_option('height')
      + border_height
  end

  return {
    relative = 'editor',
    row = window_row,
    col = window_column,
    width = window_width,
    height = window_height,
    focusable = false,
    style = 'minimal',
    border = vim.g.code_action_menu_window_border or 'single',
  }
end

-- This function makes sure that all windows in a stack have the same size which
-- relates to the widest buffer.
-- It makes the assumation that stack windows get opened one after each other.
-- This means that we only need to check the last window in the stack because
-- all other windows must have the same width as well. Just because for each of
-- them this function has run.
function StackingWindow:after_opened()
  local last_window = self.window_stack[#self.window_stack]

  if not last_window.is_anchor then
    local own_width = buffer_utils.get_buffer_width(self.buffer_number)
    local last_width = buffer_utils.get_buffer_width(last_window.buffer_number)

    if last_width >= own_width then
      self:set_window_width(last_width)
    else
      for _, window in ipairs(self.window_stack) do
        if not window.is_anchor then
          window:set_window_width(own_width)
        end
      end
    end
  end
end

return StackingWindow

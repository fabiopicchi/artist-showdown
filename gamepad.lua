local ipairs = ipairs
local setmetatable = setmetatable
local utils = require "utils"

local gamepad = {}
setfenv (1, gamepad)

local gamepadButtons = {
    "a",
    "b",
    "x",
    "y",
    "rightshoulder",
    "leftshoulder",
    "rightstick",
    "leftstick",
    "back",
    "guide",
    "start",
    "dpup",
    "dpdown",
    "dpright",
    "dpleft"
}

local gamepadAxes = {
    "leftx",
    "lefty",
    "rightx",
    "righty",
    "triggerleft",
    "triggerright"
}

-- Button state data structure
local ButtonState = utils.defineStruct ({pressed = false})

-- Axis state data structure
local AxisState = utils.defineStruct ({value = 0})

-- Gamepad state data structure
local GamepadState = utils.defineStruct (
function ()
    local instance = {}
    
    for i, value in ipairs(gamepadButtons) do
        instance[value] = ButtonState()
    end

    for i, value in ipairs(gamepadAxes) do
        instance[value] = AxisState()
    end
   
    return instance
end
)

Gamepad = utils.defineClass (
function (self, bufferSize,id)
    self.id = id
    self.bufferSize = bufferSize
    self.currentStateIndex = 1
    self.inputBuffer = {}
    for i = 1, self.bufferSize do
        self.inputBuffer[i] = GamepadState()
    end
end
)

function Gamepad:update()
    local nextStateIndex = (self.currentStateIndex % self.bufferSize) + 1
    self.inputBuffer[nextStateIndex], self.currentStateIndex = utils.copyTable(self.inputBuffer[self.currentStateIndex]), nextStateIndex
end

function Gamepad:updateButton(button, buttonState)
    self.inputBuffer[self.currentStateIndex][button].pressed = buttonState
end

function Gamepad:updateAxis(axis, axisValue)
    self.inputBuffer[self.currentStateIndex][axis].value = axisValue
end

function Gamepad:buttonPressed(button, frameTolerance)
    if not frameTolerance then frameTolerance = 0
    elseif frameTolerance > self.bufferSize - 1 then frameTolerance = self.bufferSize - 1 end    

    for i = self.currentStateIndex, self.currentStateIndex - frameTolerance, -1 do
        local current = ((i - 1) % self.bufferSize) + 1
        if self.inputBuffer[current][button].pressed then
            return true
        end
    end
    return false
end

function Gamepad:buttonJustPressed(button, frameTolerance)
    if not frameTolerance then frameTolerance = 0
    elseif frameTolerance > self.bufferSize - 2 then frameTolerance = self.bufferSize - 2 end    

    for i = self.currentStateIndex, self.currentStateIndex - frameTolerance, -1 do
        local current = ((i - 1) % self.bufferSize) + 1
        local previous = ((i - 2) % self.bufferSize) + 1

        if self.inputBuffer[current][button].pressed and not self.inputBuffer[previous][button].pressed then
            return true
        end
    end
    return false
end

function Gamepad:buttonJustReleased(button, frameTolerance)
    if not frameTolerance then frameTolerance = 0
    elseif frameTolerance > self.bufferSize - 2 then frameTolerance = self.bufferSize - 2 end

    for i = self.currentStateIndex, self.currentStateIndex - frameTolerance, -1 do
        local current = ((i - 1) % self.bufferSize) + 1
        local previous = ((i - 2) % self.bufferSize) + 1
       
        if not self.inputBuffer[current][button].pressed and self.inputBuffer[previous][button].pressed then
            return true
        end
    end
    return false
end

return gamepad

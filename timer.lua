local utils = require "utils"
local pairs = pairs
local math = math
local constants = require "constants"

local timer = {}
setfenv (1, timer)

local Event = utils.defineStruct({
    elapsed = 0,
    duration = 0,
    callback = nil
})

Timer = utils.defineClass(function (self)
    self.eventList = {}
    self.timerId = 1
end)

function Timer:start(frameDuration, callback)
    local e = Event()
    e.frameDuration = frameDuration
    e.callback = callback
    e.timerId = self.timerId

    self.timerId = self.timerId + 1
    self.eventList[e.timerId] = e

    return e.timerId
end

function Timer:clear(id)
    if self.eventList[id] then
        self.eventList[id].timerId = nil
        self.eventList[id] = nil
    end
end

function Timer:update()
    for id, event in pairs(self.eventList) do
        if event.elapsed >= event.frameDuration then
            event.callback()
            self.eventList[id] = nil
            event.timerId = nil
        end

        event.elapsed = event.elapsed + 1
    end
end

return timer

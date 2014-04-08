local utils = require "utils"

local circularBuffer = {}
setfenv (1, circularBuffer)

CircularBuffer = utils.defineClass (
function (self, list)
    self.bufferSize = #list
    self.headIndex = 1
    self.list = list
end)

function CircularBuffer:size ()
    return #self.list
end

function CircularBuffer:element (index)
    local absoluteIndex = ((index - 1) % self.bufferSize) + 1
    return self.list[absoluteIndex]
end

function CircularBuffer:insertElement (e)
    local nextHead = (self.headIndex % self.bufferSize) + 1
    self.list[nextHead], self.headIndex = e, nextHead
end

function CircularBuffer:head ()
    return self.list[self.headIndex]
end

function iterator (cB, range)
    local i = cB.headIndex
    if range == nil then
        range = cB.bufferSize
    end

    return function ()
        local currentIndex = ((i - 1) % cB.bufferSize) + 1
        if i >= cB.headIndex - range then
            i = i - 1
            return currentIndex, cB.list[currentIndex]
        end
    end
end

return circularBuffer

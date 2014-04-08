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

function iterator (cB)
    local i = cB.headIndex
    local size = cB.bufferSize
    return function ()
        local currentIndex = ((i - 1) % size) + 1
            i = i - 1
        if i >= cB.headIndex - size then
            return currentIndex, cB.list[currentIndex]
        end
    end
end

return circularBuffer

local utils = require "utils"
local pairs = pairs

local flagManager = {}
setfenv (1, flagManager)

local Flag = utils.defineStruct ({
    update = nil,
    onEnter = nil,
    onLeave = nil,
    state = false
})

FlagManager = utils.defineClass (function (self)
    self.flagList = {} 
end)

function FlagManager:addFlag(id, update, onEnter, onLeave)
    if id then
        flag = Flag()
        flag.update = update
        flag.onEnter = onEnter
        flag.onLeave = onLeave
        self.flagList[id] = flag
    end
end

function FlagManager:setFlag(id)
    if not self.flagList[id].state then
        self.flagList[id].state = true

        if self.flagList[id].onEnter then
            self.flagList[id].onEnter()
        end
    end
end

function FlagManager:resetFlag(id)
    if self.flagList[id].state then
        self.flagList[id].state = false

        if self.flagList[id].onLeave then
            self.flagList[id].onLeave()
        end
    end
end

function FlagManager:isFlagSet(id)
    return self.flagList[id].state
end

function FlagManager:areFlagsSet(table)
    for i = 1, #table do
        if not self:isFlagSet(table[i]) then
            return false
        end
    end
    return true
end

function FlagManager:isOneFlagSet(table)
    for i = 1, #table do
        if self:isFlagSet(table[i]) then
            return true
        end
    end
    return false
end

function FlagManager:update()
    for id, flag in pairs(self.flagList) do
        if flag.update and flag.state then 
            flag.update() 
        end
    end
end

return flagManager

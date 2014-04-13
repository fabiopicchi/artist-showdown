local love = love
local pairs = pairs

local utils = require "utils"

local context = {}
setfenv (1, context)

local entityId = 1

Context = utils.defineClass (function (self)
    self.entityList = {}
end)

function Context:init()

end

function Context:addEntity (entity)
    self.entityList[entityId] = entity
    entity.entityId = entityId

    entityId = entityId + 1
    return entity
end

function Context:removeEntity (entity)
    self.entityList[entity.entityId] = nil
end

function Context:update ()
    for id, entity in pairs(self.entityList) do
        entity:update()
    end
end

function Context:draw ()
    for id, entity in pairs(self.entityList) do
        entity:draw()
    end
end

return context

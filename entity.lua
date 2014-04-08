local utils = require "utils"
local setmetatable = setmetatable
local table = table
local pairs = pairs

local entity = {}
setfenv (1, entity)

Entity = utils.defineClass(
function (self)
    self.componentList = {}
    self.componentId = 1
end
)

function Entity:addComponent (component)
    self.componentList[self.componentId] = component
    component.componentId = self.componentId
    self.componentId = self.componentId + 1
    if component.added then 
        component:added(self) 
    end
    return component
end

function Entity:removeComponent (component)
    if component.componentId then
        self.componentList[component.componentId] = nil
        component.componentId = nil
        if component.removed then 
            component:removed() 
        end
    end
end

function Entity:update()
    for id, component in pairs(self.componentList) do
        if component.update then 
            component:update() 
        end
    end
end

function Entity:draw()
    for id, component in pairs(self.componentList) do
        if component.draw then 
            component:draw() 
        end
    end
end

return entity

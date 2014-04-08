local utils = require "utils"
local entity = require "entity"
local hitbox = require "hitbox"
local shape = require "shape"
local unpack = unpack

local box = {}
setfenv (1, box)

Box = utils.inheritsFrom (entity.Entity, function (self, x, y, width, height, color)
    entity.Entity.__constructor (self)
    self.hitbox = self:addComponent(hitbox.Hitbox(width, height, "wall"))
    self.hitbox.position.x, self.hitbox.position.y = x, y
    self.hitbox.immovable = true
   
    if color then
        self.graphic = self:addComponent(shape.rectangle (width, height, color))
        self.graphic:setReference (self.hitbox.position)
    end
end)

return box

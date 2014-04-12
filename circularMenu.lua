local math = math
local utils = require "utils"
local entity = require "entity"

local circularMenu = {}
setfenv(1, circularMenu)

local TWEEN_TIME = 10

CircularMenu = utils.inheritsFrom(entity.Entity, function (self, menu, assets, center, radius, inclination)
    entity.Entity.__constructor (self)

    self.menu = menu
    self.assets = assets
    self.radius = radius
    self.center = center
    self.inclination = inclination
    self.angleIncrement = 2 * math.pi / #self.assets
    self.position = 1
    self.nextPosition = 1
    self.positionIncrement = 0
    
    for i = 1, #self.assets do 
        self:addComponent(self.assets[i])
    end

    self:updateElements()
end)

function CircularMenu:moveRight ()
    self.menu:nextOption()
    self.nextPosition = self.nextPosition - 1
    self.positionIncrement = (self.nextPosition - self.position) / TWEEN_TIME
    self:updateElements()
end

function CircularMenu:moveLeft ()
    self.menu:previousOption()
    self.nextPosition = self.nextPosition + 1
    self.positionIncrement = (self.nextPosition - self.position) / TWEEN_TIME
    self:updateElements()
end

function CircularMenu:updateElements ()
    for i = 1, #self.assets do
        local img = self.assets[(i - 1) % #self.assets + 1]
        
        img.x = self.center.x + math.sin(self.angleIncrement * (i + (self.position - 1) - 1)) * self.radius
        img.y = self.center.y + math.cos(self.angleIncrement * (i + (self.position - 1) - 1)) * self.radius * math.sin(self.inclination)

        img.scale.x = 0.5 + 0.5 * ((1 + math.cos(self.angleIncrement * (i + (self.position - 1) - 1))) / 2) * math.cos(self.inclination)
        img.scale.y = 0.5 + 0.5 * ((1 + math.cos(self.angleIncrement * (i + (self.position - 1) - 1))) / 2) * math.cos(self.inclination)

        img.x = img.x - img.width * img.scale.x / 2
        img.y = img.y - img.height * img.scale.y / 2
    end
end

function CircularMenu:update ()
    if (self.position < self.nextPosition and self.positionIncrement > 0) or (self.position > self.nextPosition and self.positionIncrement < 0) then
        self.position = self.position + self.positionIncrement
        self:updateElements()

        if (self.position >= self.nextPosition and self.positionIncrement > 0) or (self.position <= self.nextPosition and self.positionIncrement < 0) then
            self.position = self.nextPosition
            self:updateElements ()
        end
    end
end

return circularMenu

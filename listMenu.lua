local utils = require "utils"
local entity = require "entity"
local love = love

local listMenu = {}
setfenv(1, listMenu)

local function updateMarker (listMenu)
    local currentAsset = listMenu.assets[listMenu.menu.option]

    listMenu.marker.x = currentAsset.x - listMenu.marker.width - listMenu.markerDistance
    listMenu.marker.y = currentAsset.y + (currentAsset.height - listMenu.marker.height) / 2

end

ListMenu = utils.inheritsFrom(entity.Entity, function (self, menu, assets, marker, position, separation, markerDistance)
    entity.Entity.__constructor (self)

    self.menu = menu
    self.assets = assets
    self.separation = separation
    self.marker = marker
    self.position = position
    self.markerDistance = markerDistance
    
    local y = self.position.y
    for i = 1, #self.assets do 
        local optionAsset = self.assets[i]

        self:addComponent(optionAsset)
        optionAsset.x = self.position.x - optionAsset.width / 2
        optionAsset.y = y
        y = y + optionAsset.height + self.separation
    end

    self:addComponent(self.marker)
    updateMarker (self)

    self.select = love.audio.newSource("assets/sound/sfx/menu_accept.ogg")
    self.side = love.audio.newSource("assets/sound/sfx/menu_side.ogg")
end)

function ListMenu:update ()
    entity.Entity.update (self)

    if self.gamepad then
        if self.gamepad:buttonJustPressed("dpup") then
            self:moveUp()
        elseif self.gamepad:buttonJustPressed("dpdown") then
            self:moveDown()
        elseif self.gamepad:buttonJustPressed("a") then
            self.menu:selectOption()
        end
    end

    updateMarker(self)
end


function ListMenu:moveDown ()
    self.menu:nextOption()
    updateMarker (self)
    love.audio.play(self.side)
end

function ListMenu:moveUp ()
    self.menu:previousOption()
    updateMarker (self)
    love.audio.play(self.side)
end

return listMenu

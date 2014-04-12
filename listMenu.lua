local utils = require "utils"
local entity = require "entity"

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
end)

function ListMenu:moveDown ()
    self.menu:nextOption()
    updateMarker (self)
end

function ListMenu:moveUp ()
    self.menu:previousOption()
    updateMarker (self)
end

return listMenu

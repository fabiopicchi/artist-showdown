local referrer = require "referrer"
local utils = require "utils"
local love = love

local image = {}
setfenv (1, image)

Image = utils.inheritsFrom (referrer.Referrer, function (self, file)
    referrer.Referrer.__constructor(self)

    self.img = love.graphics.newImage (file)
    self.width = self.img:getWidth()
    self.height = self.img:getHeight()
    self.rotation = 0
    self.scale = {x = 1, y = 1}
    self.visible = true
end)

function Image:draw ()
    if self.visible then
        love.graphics.reset()
        love.graphics.draw (self.img, self.reference.x + self.x, self.reference.y + self.y, self.rotation, self.scale.x, self.scale.y)
    end
end

return image

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
end)

function Image:draw ()
     love.graphics.reset()
     love.graphics.draw (self.img, self.reference.x + self.x, self.reference.y + self.y)
end

return image

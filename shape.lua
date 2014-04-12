local utils = require "utils"
local referrer = require "referrer"
local love = love
local unpack = unpack

local shape = {}
setfenv (1, shape)

function rectangle (width, height, color)
    local s = referrer.Referrer()
    
    s.width = width
    s.height = height
    s.color = color
    s.scale = {x = 1, y = 1}

    s.draw = function (self)
        love.graphics.setColor (unpack(self.color))
        love.graphics.rectangle ("fill", self.reference.x + self.x, self.reference.y + self.y, self.width * s.scale.x, self.height * s.scale.y)
    end

    return s
end

return shape

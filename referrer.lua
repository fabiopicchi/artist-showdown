local utils = require "utils"
local tostring = tostring

local referrer = {}
setfenv (1, referrer)

local DEFAULT_REFERENCE = {x = 0, y = 0}

Referrer = utils.defineClass (function (self) 
    self.x = 0
    self.y = 0
    self.reference = DEFAULT_REFERENCE
end)

function Referrer:setReference (reference)
    self.reference = reference
end

function Referrer:removeReference (reference)
    self.reference = DEFAULT_REFERENCE
end

return referrer

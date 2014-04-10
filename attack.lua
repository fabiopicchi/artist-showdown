local hitbox = require "hitbox"
local shape = require "shape"
local utils = require "utils"
local love = love

local attack = {}
setfenv (1, attack)

AttackHitbox = utils.inheritsFrom (hitbox.Hitbox, function (self, width, height, knockback, offset, setup, duration, accomodation, meteorSpeed)
    hitbox.Hitbox.__constructor (self, width, height, "attack")

    self.knockback = knockback
    self.offset = offset
    self.setup = setup
    self.duration = duration
    self.accomodation = accomodation

    if meteorSpeed then  
        self.meteor = true
        self.meteorSpeed = meteorSpeed
    else            
        self.meteor = false
    end

    self.graphic = shape.rectangle (self.width, self.height, {0, 255, 0, 255})
    self.graphic:setReference (self.position)
end)

function AttackHitbox:added (parent)
    hitbox.Hitbox.added (self, parent)

    self.position.x = self.parent.hitbox.position.x + self.offset.x + (self.parent.hitbox.width/2 - self.width/2)
    self.position.y = self.parent.hitbox.position.y + self.offset.y + (self.parent.hitbox.height/2 - self.height/2)
end

function AttackHitbox:update ()
    self.speed.x = self.parent.hitbox.speed.x
    self.speed.y = self.parent.hitbox.speed.y

    hitbox.Hitbox.update(self)
end

function AttackHitbox:draw ()
    -- self.graphic:draw()
end

Attack = utils.defineClass (function (self, attackHitboxList, direction, button, chargeSetup)
    self.hitboxList = attackHitboxList
    self.direction = direction
    self.button = button
    self.chargeSetup = chargeSetup
end)

function Attack:getHitbox (chargeLevel, meteor)
    if not meteor then
        return self.hitboxList[chargeLevel]
    else
        return self.hitboxList["meteor_" .. chargeLevel]
    end
end

return attack

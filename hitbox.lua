local tostring = tostring
local utils = require "utils"
local math = math
local string = string
local table = table
local pairs = pairs
local type = type

local hitbox = {}
setfenv(1, hitbox)

TOP = "top"
LEFT = "left"
RIGHT = "right"
BOTTOM = "bottom"
NONE = "none"

local precision = 0.000001
local function eq (a, b)
    return (a > b - precision and a < b + precision)
end
local function le (a, b)
        return (a > b - precision and a < b + precision) or
                (a + precision < b - precision)
end
local function lt (a, b)
    return (a + precision < b - precision)
end
local function gt (a, b)
    return lt (b, a)
end
local function ge (a, b)
    return le (b, a)
end

local collisionGroups = {}
local hitboxId = 1

Hitbox = utils.defineClass(function (self, width, height, collisionGroup)
    self.collisionGroup = collisionGroup
    self.width = width
    self.height = height
    self.position = {x = 0, y = 0}
    self.lastPosition = {x = 0, y = 0}
    self.speed = {x = 0, y = 0}
    self.maxSpeed = {x = -1, y = -1}
    self.acceleration = {x = 0, y = 0}
    self.immovable = false
    self.touching = NONE
    self.lastTouching = NONE
end)

local function overlapHitboxes (h1, h2, callback)
    if le (h1.lastPosition.x, h2.position.x + h2.width) and
    ge (h1.position.x + h1.width, h2.lastPosition.x) and
    le (h1.lastPosition.y, h2.position.y + h2.height) and
    ge (h1.position.y + h1.height, h2.lastPosition.y) then
        if callback then 
            callback (h1, h2) 
        end
        return true
    else
        return false
    end
end

function overlap (h1, h2, callback)
    if type(h1) == "string" then
        if not collisionGroups[h1] then return end
        for id, hitbox in pairs(collisionGroups[h1]) do
            overlap (hitbox, h2, callback)
        end
    elseif type(h2) == "string" then
        if not collisionGroups[h2] then return end
        for id, hitbox in pairs(collisionGroups[h2]) do
            overlapHitboxes (h1, hitbox, callback)
        end
    else
        overlapHitboxes (h1, h2, callback)
    end

end

local function collideHitboxes (h1, h2)
    if overlapHitboxes (h1, h2) then
        if h1.touching == NONE then h1.touching = "" end
        if h2.touching == NONE then h2.touching = "" end

        local h1Delta = {x = h1.position.x - h1.lastPosition.x, y = h1.position.y - h1.lastPosition.y}
        local h2Delta = {x = h2.position.x - h2.lastPosition.x, y = h2.position.y - h2.lastPosition.y}
        local delta = {x = h1Delta.x - h2Delta.x, y = h1Delta.y - h2Delta.y}

        local toi = {x = -1, y = -1}
        
        -- distance to stay at the left side of the object
        local xDistanceLeft = h2.lastPosition.x - h1.lastPosition.x - h1.width
        -- distance to stay at the right side of the object
        local xDistanceRight = h2.lastPosition.x + h2.width - h1.lastPosition.x
        -- distance to stay on top of the object
        local yDistanceTop = h2.lastPosition.y - h1.lastPosition.y - h1.height
        -- distance to stay at the bottom of the object
        local yDistanceBottom = h2.lastPosition.y + h2.height - h1.lastPosition.y

        local xDistance = nil
        local yDistance = nil

        if not eq(delta.x, 0) then
            if gt(delta.x, 0) then
                xDistance = xDistanceLeft
            elseif lt(delta.x, 0) then
                xDistance = xDistanceRight
            end

            if le(math.abs(xDistance), math.abs(delta.x)) then toi.x = xDistance / delta.x end
        end

        if not eq(delta.y, 0) then
            if gt(delta.y, 0) then
                yDistance = yDistanceTop
            elseif lt(delta.y, 0) then
                yDistance = yDistanceBottom
            end

            if le (math.abs(yDistance), math.abs(delta.y)) then toi.y = yDistance / delta.y end
        end

        if toi.x > toi.y and lt(h1.position.y, h2.position.y + h2.height) and gt(h1.position.y + h1.height, h2.position.y) then
            h1.position.x = h1.lastPosition.x + xDistance
            h1.speed.x = 0
            h2.speed.x = 0
        elseif toi.x < toi.y and lt(h1.position.x, h2.position.x + h2.width) and gt(h1.position.x + h1.width, h2.position.x) then
            h1.position.y = h1.lastPosition.y + yDistance
            h1.speed.y = 0
            h2.speed.y = 0
        elseif eq (toi.x, -1) then
        end

        if eq (h1.position.x + h1.width, h2.position.x) and ge(delta.x, 0) then
            h1.touching = h1.touching .. "_" .. RIGHT
            h2.touching = h2.touching .. "_" .. LEFT
        elseif eq (h1.position.x, h2.position.x + h2.width) and le(delta.x, 0) then
            h2.touching = h2.touching .. "_" .. RIGHT
            h1.touching = h1.touching .. "_" .. LEFT
        end

        if eq (h1.position.y + h1.height, h2.position.y) and ge(delta.y, 0) then 
            h1.touching = h1.touching .. "_" .. BOTTOM
            h2.touching = h2.touching .. "_" .. TOP
        elseif eq (h1.position.y, h2.position.y + h2.height) and le(delta.y, 0) then
            h2.touching = h2.touching .. "_" .. BOTTOM
            h1.touching = h1.touching .. "_" .. TOP
        end
    end
end

function collide (h1, h2)
    if type(h1) == "string" then
        if not collisionGroups[h1] then return end
        for id, hitbox in pairs(collisionGroups[h1]) do
            collide (hitbox, h2)
        end
    elseif type(h2) == "string" then
        if not collisionGroups[h2] then return end
        for id, hitbox in pairs(collisionGroups[h2]) do
            collideHitboxes (h1, hitbox)
        end
    else
        collideHitboxes (h1, h2)
    end
end

local function limitValue (val, limit)
    if limit >= 0 then
        if val < 0 then
            val = math.max(val, -limit)
        else
            val = math.min(val, limit)
        end
    end

    return val
end

function Hitbox:added (parent)
    if collisionGroups[self.collisionGroup] == nil then
        collisionGroups[self.collisionGroup] = {}
    end
    collisionGroups[self.collisionGroup][hitboxId] = self
    self.hitboxId = hitboxId
    hitboxId = hitboxId + 1

    self.parent = parent
end

function Hitbox:removed ()
    self.parent = nil
    collisionGroups[self.collisionGroup][self.hitboxId] = nil
end

function Hitbox:update()
    self.touching, self.lastTouching = NONE, self.touching
    self.lastPosition.x, self.lastPosition.y = self.position.x, self.position.y
    self.position.x, self.position.y = self.position.x + self.speed.x + self.acceleration.x * 0.5, self.position.y + self.speed.y + self.acceleration.y * 0.5
    self.speed.x, self.speed.y = limitValue(self.speed.x + self.acceleration.x, self.maxSpeed.x), limitValue(self.speed.y + self.acceleration.y, self.maxSpeed.y)
end

function Hitbox:isTouching(dir)
    if dir == NONE and self.touching == NONE or string.find(self.touching, dir) then return true
    else return false
    end
end

function Hitbox:wasTouching(dir)
    if dir == NONE and self.lastTouching == NONE or string.find(self.lastTouching, dir) then return true
    else return false
    end
end

return hitbox

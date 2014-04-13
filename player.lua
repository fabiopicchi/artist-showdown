local math = math
local love = love
local pairs = pairs

local utils = require "utils"
local shape = require "shape"
local timer = require "timer"
local entity = require "entity"
local hitbox = require "hitbox"
local framedata = require "framedata"
local animation = require "animation"
local attackData = require "attackData"
local flagManager = require "flagManager"

local player = {}
setfenv (1, player)

local WIDTH = 50
local HEIGHT = 100
local SPEED = 13
local JUMP_HEIGHT = 1.8 * HEIGHT
local DOUBLE_JUMP_HEIGHT = 0.9 * HEIGHT
local JUMP_DURATION = 12
local GRAVITY = 2 * JUMP_HEIGHT / (JUMP_DURATION * JUMP_DURATION)
local JUMP_SPEED = GRAVITY * JUMP_DURATION
local DOUBLE_JUMP_SPEED = math.sqrt (2 * GRAVITY * DOUBLE_JUMP_HEIGHT)
local MAX_Y_SPEED = 35
local SHORT_HOP_HEIGHT = 0.9 * HEIGHT
local DASH_LENGTH = 3 * WIDTH
local DASH_DURATION = 6
local DASH_COOLDOWN = 8
local INVINCIBILITY_DURATION = 4
local DASH_SPEED = DASH_LENGTH / DASH_DURATION
local SHORT_HOP_THRESHOLD = 0.6 * HEIGHT
local BLOCK_PREPARATION = 5
local MAX_CHARGE_TIME = 30
local ANIMATION_OFFSET_RIGHT_X = -105
local ANIMATION_OFFSET_LEFT_X = 157
local ANIMATION_OFFSET_Y = -130
local BLOCK_DRAG = 1
local TAUNT_SETUP = 18

local hitSounds = {
    love.audio.newSource ("assets/sound/sfx/hit_01.ogg"),    
    love.audio.newSource ("assets/sound/sfx/hit_02.ogg"),    
    love.audio.newSource ("assets/sound/sfx/hit_03.ogg")
}

local heavyHitSounds = {
    love.audio.newSource ("assets/sound/sfx/heavyhit_01.ogg"),    
    love.audio.newSource ("assets/sound/sfx/heavyhit_02.ogg")
}

local dashSounds = {
    love.audio.newSource ("assets/sound/sfx/dash.ogg")
}

local attackSounds = {
    love.audio.newSource ("assets/sound/sfx/attack_woosh.ogg")
}

local landingSounds = {
    love.audio.newSource ("assets/sound/sfx/land.ogg")
}

local hitWallSounds = {
    love.audio.newSource ("assets/sound/sfx/hit_wall_01.ogg"),
    love.audio.newSource ("assets/sound/sfx/hit_wall_02.ogg")
}

Player = utils.inheritsFrom (entity.Entity, function (self, gamepad, character)
    entity.Entity.__constructor (self)

    -- Properties
    self.facing = "right"
    self.jumpOrigin = 0
    self.chargeTime = 0
    self.points = 0
    self.timers = {}
    self.characterId = character
    self.framedata = framedata[self.characterId]
    self.attackData = attackData.AttackData()
    self.activeHitboxes = {}

    -- Components
    self.flagManager = self:addComponent(flagManager.FlagManager())
    
    -- Timer
    self.timer = self:addComponent(timer.Timer())
    
    -- Hitbox
    self.hitbox = self:addComponent(hitbox.Hitbox(50, 100, "player"))
    self.hitbox.position.x, self.hitbox.position.y = 100, 100
    self.hitbox.acceleration.y = GRAVITY
    self.hitbox.maxSpeed.y = MAX_Y_SPEED
    self.hitbox.hitCallback = function (attackHitbox)
        if not (self.flagManager:isFlagSet("INVINCIBLE") or self.activeHitboxes[attackHitbox]) then
            self.flagManager:resetFlag ("MOVING_LEFT")
            self.flagManager:resetFlag ("MOVING_RIGHT")
            self.flagManager:resetFlag ("ATTACK_LEFT")
            self.flagManager:resetFlag ("ATTACK_RIGHT")
            self.flagManager:resetFlag ("ATTACK_DOWN")
            self.flagManager:resetFlag ("ATTACK_UP")
            self.flagManager:resetFlag ("DASH")
            self.flagManager:resetFlag("HITSTUN")

            self.activeHitboxes[attackHitbox] = true
            self.hitbox.speed.x = attackHitbox.knockback.x
            self.hitbox.speed.y = attackHitbox.knockback.y

            if attackHitbox.parent.chargeTime >= MAX_CHARGE_TIME then
                love.audio.play (heavyHitSounds[love.math.random(1, #heavyHitSounds)])
            else
                love.audio.play (hitSounds[love.math.random(1, #hitSounds)])
            end

            self.flagManager:setFlag("HITSTUN")
        end
    end 
    self.hitbox.score = function ()
        if not self.flagManager:isFlagSet("TAUNTING") then
            self.points = self.points + 1
        else
            self.points = self.points + 5
        end
    end

    self.graphic = self:addComponent(shape.rectangle (WIDTH, HEIGHT, {255, 0, 0, 255}))
    self.graphic:setReference (self.hitbox.position)

    self.animation = self:addComponent(animation.Animation(self.framedata.imgFile, self.framedata.frames, self.framedata.animations))
    self.animation.x = ANIMATION_OFFSET_RIGHT_X
    self.animation.y = ANIMATION_OFFSET_Y
    self.animation:setReference (self.hitbox.position)
    self.animation:setAnimation ("IDLE")

    self.flagManager:addFlag(
    "MOVING_LEFT",
    function ()
        self.hitbox.speed.x = -SPEED
    end,
    function () 
        self.facing = "left"
        self.animation.scale.x = -1
        self.animation.x = ANIMATION_OFFSET_LEFT_X
        if self.flagManager:isFlagSet("MOVING_RIGHT") then
            self.flagManager:resetFlag("MOVING_RIGHT")
        end
    end,
    function ()
        self.hitbox.speed.x = 0
    end
    )

    self.flagManager:addFlag(
    "MOVING_RIGHT",
    function ()
        self.hitbox.speed.x = SPEED
    end,
    function ()
        self.facing = "right"
        self.animation.scale.x = 1
        self.animation.x = ANIMATION_OFFSET_RIGHT_X
        if self.flagManager:isFlagSet("MOVING_LEFT") then
            self.flagManager:resetFlag("MOVING_LEFT")
        end
    end,
    function ()
        self.hitbox.speed.x = 0
    end
    )

    self.flagManager:addFlag(
    "JUMP",
    nil,
    function ()
        self.jumpOrigin = self.hitbox.position.y
        self.hitbox.speed.y = -JUMP_SPEED
    end,
    nil
    )

    self.flagManager:addFlag(
    "FALL",
    nil,
    function ()
        self.flagManager:resetFlag("SHORT_HOP")
    end,
    nil
    )

    self.flagManager:addFlag(
    "SHORT_HOP",
    function ()
        if SHORT_HOP_THRESHOLD <= (self.jumpOrigin - self.hitbox.position.y) then
            self.flagManager:resetFlag("SHORT_HOP")
            if SHORT_HOP_HEIGHT >= (self.jumpOrigin - self.hitbox.position.y) then
                self.hitbox.speed.y = -math.sqrt (2 * (SHORT_HOP_HEIGHT - (self.jumpOrigin - self.hitbox.position.y)) * GRAVITY)
            end
        end
    end,
    nil,
    nil
    )

    self.flagManager:addFlag(
    "DOUBLE_JUMP",
    nil,
    function ()
        self.jumpOrigin = self.hitbox.position.y
        self.hitbox.speed.y = -DOUBLE_JUMP_SPEED
    end,
    nil
    )

    self.flagManager:addFlag(
    "DASH",
    nil,
    function ()
        self.flagManager:resetFlag("MOVING_LEFT")
        self.flagManager:resetFlag("MOVING_RIGHT")
        self.hitbox.speed.x = self.facing == "right" and DASH_SPEED or -DASH_SPEED
        self.hitbox.speed.y = 0
        self.hitbox.acceleration.y = 0 

        self.timers["dash"] = self.timer:start(DASH_DURATION, function () self.flagManager:resetFlag("DASH") end)
        self.timers["invincible"] = self.timer:start((DASH_DURATION - INVINCIBILITY_DURATION) / 2, function ()
            self.flagManager:setFlag ("INVINCIBLE")
        end)
    end,
    function ()
        love.audio.play (dashSounds[1])
        self.timer:clear(self.timers["dash"])
        self.timer:clear(self.timers["invincible"])
        self.hitbox.speed.x = 0
        self.hitbox.acceleration.y = GRAVITY
        self.flagManager:setFlag("DASH_COOLDOWN")
    end
    )

    self.flagManager:addFlag(
    "DASH_COOLDOWN",
    nil,
    function ()
        self.timer:start(DASH_COOLDOWN, function () self.flagManager:resetFlag("DASH_COOLDOWN") end)
    end
    )

    self.flagManager:addFlag(
    "INVINCIBLE",
    nil,
    function ()
        self.timer:start(INVINCIBILITY_DURATION, function () self.flagManager:resetFlag("INVINCIBLE") end)
        self.graphic.color = {255, 255, 255, 255}
    end,
    function ()
        self.graphic.color = {255, 0, 0, 255}
    end
    )

    self.flagManager:addFlag(
    "BLOCK",
    nil,
    function ()
        self.flagManager:resetFlag("MOVING_LEFT")
        self.flagManager:resetFlag("MOVING_RIGHT")

        self.hitbox.speed.x = 0
        self.hitbox.speed.y = 0

        self.timers["startBlock"] = self.timer:start(BLOCK_PREPARATION, function ()
            self.graphic.color = {255, 0, 255, 255}

            self.flagManager:setFlag("BLOCKING")
        end)
    end,
    function ()
        self.graphic.color = {255, 0, 0, 255}
        self.flagManager:resetFlag("BLOCKING")
        self.timer:clear(self.timers["startBlock"])
    end
    )

    self.flagManager:addFlag("BLOCKING")

    local function prepareAttack (attack)
        self.flagManager:resetFlag("MOVING_LEFT")
        self.flagManager:resetFlag("MOVING_RIGHT")

        self.hitbox.speed.x = 0
        self.hitbox.speed.y = JUMP_SPEED / 10
        self.hitbox.acceleration.y = 0
        self.chargeTime = 0

        self.attack = attack
        self.flagManager:setFlag("ATTACK_CHARGE_SETUP")
    end

    local function interruptAttack ()
        self.timer:clear (self.timers["chargeStup"])
        self.timer:clear (self.timers["attackSetup"])
        self.timer:clear (self.timers["attackDuration"])
        self.timer:clear (self.timers["attackAccomodation"])

        self.hitbox.acceleration.y = GRAVITY
        self.hitbox.maxSpeed.y = JUMP_SPEED

        if self.attackHitbox then self:removeComponent (self.attackHitbox) end

        self.flagManager:resetFlag("ATTACK_CHARGE_SETUP")
        self.flagManager:resetFlag("ATTACK_CHARGING")
        self.flagManager:resetFlag("ATTACK_SETUP")
        self.flagManager:resetFlag("ATTACKING_METEOR")
        self.flagManager:resetFlag("ATTACKING")
        self.flagManager:resetFlag("ATTACK_ACCOMODATION")
        
        self.attack = nil
        self.attackHitbox = nil
    end

    self.flagManager:addFlag(
    "ATTACK_CHARGE_SETUP",
    nil,
    function ()
        self.timers["chargeSetup"] = self.timer:start(self.attack.chargeSetup, function ()
            self.flagManager:resetFlag("ATTACK_CHARGE_SETUP")
            self.flagManager:setFlag("ATTACK_CHARGING")
        end)
    end,
    nil
    )

    self.flagManager:addFlag(
    "ATTACK_CHARGING",
    function ()
        if self.gamepad:buttonPressed(self.attack.button) then 
            self.chargeTime = self.chargeTime + 1
            if self.chargeTime >= 3 * MAX_CHARGE_TIME / 2 then
                self.flagManager:resetFlag("ATTACK_CHARGING")
                self.flagManager:setFlag("ATTACK_SETUP")
            end
        else
            self.flagManager:resetFlag("ATTACK_CHARGING")
            self.flagManager:setFlag("ATTACK_SETUP")
        end
    end,
    function ()
        if not self.gamepad:buttonPressed(self.attack.button) then 
            self.flagManager:resetFlag("ATTACK_CHARGING")
            self.flagManager:setFlag("ATTACK_SETUP")
        end
    end,
    nil
    )

    self.flagManager:addFlag(
    "ATTACK_SETUP",
    nil,
    function ()
        love.audio.play(attackSounds[1])
        if self.attack.direction ~= "DOWN" or self.hitbox:isTouching(hitbox.BOTTOM) then
            if self.chargeTime >= MAX_CHARGE_TIME then
                self.attackHitbox = self.attack:getHitbox (2)
            elseif self.chargeTime >= MAX_CHARGE_TIME / 2 then
                self.attackHitbox = self.attack:getHitbox (1)
            else
                self.attackHitbox = self.attack:getHitbox (0)
            end
        else
            if self.chargeTime >= MAX_CHARGE_TIME then
                self.attackHitbox = self.attack:getHitbox (2, true)
            elseif self.chargeTime >= MAX_CHARGE_TIME / 2 then
                self.attackHitbox = self.attack:getHitbox (1, true)
            else
                self.attackHitbox = self.attack:getHitbox (0)
            end

        end

        self.timers["attackSetup"] = self.timer:start(self.attackHitbox.setup, function ()
            self.flagManager:resetFlag("ATTACK_SETUP")
            if self.attackHitbox.meteor and not self.hitbox:isTouching (hitbox.BOTTOM) then
                self.flagManager:setFlag("ATTACKING_METEOR")
            else
                self.flagManager:setFlag("ATTACKING")
            end
        end)
    end,
    nil
    )

    self.flagManager:addFlag(
    "ATTACKING_METEOR",
    function ()
        if not self.hitbox:wasTouching(hitbox.BOTTOM) and self.hitbox:isTouching (hitbox.BOTTOM) then
            self.flagManager:resetFlag("ATTACKING_METEOR")
            self:removeComponent (self.attackHitbox)

            if self.chargeTime >= MAX_CHARGE_TIME then
                self.attackHitbox = self.attack:getHitbox(2)
            elseif self.chargeTime >= MAX_CHARGE_TIME / 2 then
                self.attackHitbox = self.attack:getHitbox(1)
            else
                self.attackHitbox = self.attack:getHitbox(0)
            end

            self.flagManager:setFlag("ATTACKING")
        end
    end,
    function ()
        self:addComponent (self.attackHitbox)
        self.hitbox.speed.y = self.attackHitbox.meteorSpeed
        self.hitbox.maxSpeed.y = self.attackHitbox.meteorSpeed
    end,
    nil
    )

    self.flagManager:addFlag(
    "ATTACKING",
    nil,
    function ()
        self:addComponent (self.attackHitbox)
        self.timers["attackDuration"] = self.timer:start(self.attackHitbox.duration, function ()
            self.flagManager:setFlag("ATTACK_ACCOMODATION")
            self.flagManager:resetFlag("ATTACKING")
        end)
    end,
    nil
    )

    self.flagManager:addFlag(
    "ATTACK_ACCOMODATION",
    nil,
    function ()
        self.timers["attackAccomodation"] = self.timer:start(self.attackHitbox.accomodation, function ()
            self.flagManager:resetFlag("ATTACK_" .. self.attack.direction)
        end)
    end,
    nil
    )

    self.flagManager:addFlag(
    "ATTACK_LEFT",
    nil,
    function ()
        self.facing = "left"
        self.animation.scale.x = -1
        self.animation.x = ANIMATION_OFFSET_LEFT_X
        prepareAttack(self.attackData.left)
    end,
    interruptAttack)

    self.flagManager:addFlag(
    "ATTACK_RIGHT",
    nil,
    function ()
        self.facing = "right"
        self.animation.scale.x = 1
        self.animation.x = ANIMATION_OFFSET_RIGHT_X
        prepareAttack(self.attackData.right)
    end,
    interruptAttack)

    self.flagManager:addFlag(
    "ATTACK_UP",
    nil,
    function ()
        prepareAttack(self.attackData.up)
    end,
    interruptAttack)

    self.flagManager:addFlag(
    "ATTACK_DOWN",
    nil,
    function ()
        prepareAttack(self.attackData.down)
    end,
    interruptAttack
    )

    self.flagManager:addFlag(
    "HITSTUN",
    function ()
        if not self.hitbox:wasTouching(hitbox.BOTTOM) and self.hitbox:isTouching(hitbox.BOTTOM) then
            self.hitbox.acceleration.x = self.hitbox.speed.x > 0 and -BLOCK_DRAG or BLOCK_DRAG
        end

        if (not self.hitbox:wasTouching(hitbox.LEFT) and self.hitbox:isTouching(hitbox.LEFT)) or
            (not self.hitbox:wasTouching(hitbox.RIGHT) and self.hitbox:isTouching(hitbox.RIGHT)) then
            love.audio.play(hitWallSounds[love.math.random(1, #hitWallSounds)])
        end

        if self.hitbox.acceleration.x ~= 0 and (self.hitbox.acceleration.x * self.hitbox.speed.x >= 0 or not self.hitbox:isTouching(hitbox.BOTTOM)) then
            self.hitbox.speed.x = 0
            self.hitbox.acceleration.x = 0
            
            for hitbox, status in pairs (self.activeHitboxes) do
                self.activeHitboxes[hitbox] = nil
            end

            self.flagManager:resetFlag("HITSTUN")
        end
    end,
    function ()
        if self.flagManager:isFlagSet ("BLOCKING") then
            self.hitbox.speed.x = self.hitbox.speed.x / 2
            self.hitbox.acceleration.x = self.hitbox.speed.x > 0 and -BLOCK_DRAG or BLOCK_DRAG
            self.hitbox.speed.y = 0
        end

        if self.hitbox:isTouching(hitbox.BOTTOM) and self.hitbox.speed.y > 0 then
            self.hitbox.speed.y = -self.hitbox.speed.y * 2
        end

        if self.hitbox.speed.x > 0 then
            self.facing = "left"
            self.animation.scale.x = -1
            self.animation.x = ANIMATION_OFFSET_LEFT_X
        elseif self.hitbox.speed.x < 0 then
            self.facing = "right"
            self.animation.scale.x = 1
            self.animation.x = ANIMATION_OFFSET_RIGHT_X
        end
    end,
    nil
    )

    self.flagManager:addFlag(
    "TAUNT",
    nil,
    function ()
        self.timers["tauntSetup"] = self.timer:start(TAUNT_SETUP, function ()
            self.flagManager:setFlag("TAUNTING")
        end)
    end,
    function ()
        self.flagManager:resetFlag("TAUNTING")
        self.timer:clear(self.timers["tauntSetup"])
    end
    )

    self.flagManager:addFlag("TAUNTING")

    -- self.flagManager:addFlag("EXPRESSION")
    self.gamepad = gamepad

end)

function Player:canMove()
    return (not self.flagManager:isOneFlagSet({"TAUNT", "DASH", "BLOCK", "ATTACK_LEFT", "ATTACK_RIGHT", "ATTACK_UP", "ATTACK_DOWN", "HITSTUN"}))
end

function Player:canJump()
    return (self.hitbox:isTouching(hitbox.BOTTOM) and not self.flagManager:isOneFlagSet({"TAUNT", "DASH", "BLOCK", "ATTACK_LEFT", "ATTACK_RIGHT", "ATTACK_UP", "ATTACK_DOWN", "HITSTUN"}))
end

function Player:canDoubleJump()
    return not (self.hitbox:isTouching(hitbox.BOTTOM) or self.flagManager:isOneFlagSet({"TAUNT", "DOUBLE_JUMP", "DASH", "BLOCK", "ATTACK_LEFT", "ATTACK_RIGHT", "ATTACK_UP", "ATTACK_DOWN", "HITSTUN"}))
end

function Player:canDash()
    return (not self.flagManager:isOneFlagSet({"TAUNT", "DASH", "DASH_COOLDOWN", "BLOCK", "ATTACK_LEFT", "ATTACK_RIGHT", "ATTACK_UP", "ATTACK_DOWN", "HITSTUN"}))
end

function Player:canAttack()
    return (not self.flagManager:isOneFlagSet({"TAUNT", "DASH", "BLOCK", "ATTACK_LEFT", "ATTACK_RIGHT", "ATTACK_UP", "ATTACK_DOWN", "HITSTUN"}))
end

function Player:canTaunt()
    return (not self.flagManager:isOneFlagSet({"TAUNT", "DASH", "BLOCK", "ATTACK_LEFT", "ATTACK_RIGHT", "ATTACK_UP", "ATTACK_DOWN", "HITSTUN", "JUMP", "DOUBLE_JUMP", "FALL"}))
end

function Player:canBlock()
    return (not self.flagManager:isOneFlagSet({"TAUNT", "DASH", "BLOCK", "ATTACK_LEFT", "ATTACK_RIGHT", "ATTACK_UP", "ATTACK_DOWN", "HITSTUN"}))
end

function Player:canShortHop()
    return (self.flagManager:isOneFlagSet({"JUMP", "DOUBLE_JUMP"}) and not self.flagManager:isOneFlagSet({"TAUNT", "FALL", "DASH", "ATTACK_LEFT", "ATTACK_RIGHT", "ATTACK_UP", "ATTACK_DOWN", "BLOCK", "HITSTUN"}))
end

function Player:update()
    if self.gamepad then
        if self:canMove() then
            if self.gamepad:buttonPressed("dpright") or self.gamepad:axisMoved("leftx", 0.5) then
                self.flagManager:setFlag("MOVING_RIGHT")
            elseif self.gamepad:buttonPressed("dpleft") or self.gamepad:axisMoved("leftx", -0.5) then 
                self.flagManager:setFlag("MOVING_LEFT")
            else
                self.flagManager:resetFlag("MOVING_RIGHT")
                self.flagManager:resetFlag("MOVING_LEFT")
            end
        end

        if self:canAttack () then
            if self.gamepad:buttonJustPressed("x", 4) then
                self.flagManager:setFlag("ATTACK_LEFT")
            elseif self.gamepad:buttonJustPressed("y", 4) then
                self.flagManager:setFlag("ATTACK_UP")
            elseif self.gamepad:buttonJustPressed("b", 4) then
                self.flagManager:setFlag("ATTACK_RIGHT")
            elseif self.flagManager:isFlagSet("DOUBLE_JUMP") and self.gamepad:buttonJustPressed("a") then
                self.flagManager:setFlag("ATTACK_DOWN")
            end
        end

        if self:canDash() and self.gamepad:buttonJustPressed("rightshoulder", 4) then 
            self.flagManager:setFlag("DASH")
        end

        if self.hitbox:isTouching(hitbox.BOTTOM) then
            self.flagManager:resetFlag("DOUBLE_JUMP")
            self.flagManager:resetFlag("JUMP")
        end

        if self:canJump() and self.gamepad:buttonJustPressed("a", 4) then
            self.flagManager:setFlag("JUMP")
        end

        if self:canDoubleJump() and self.gamepad:buttonJustPressed("a") then
            self.flagManager:setFlag("DOUBLE_JUMP")
        end

        if self.hitbox.speed.y > 0 then
            self.flagManager:setFlag("FALL")
        else
            self.flagManager:resetFlag("FALL")
        end

        if self:canShortHop() and self.gamepad:buttonJustReleased ("a") and SHORT_HOP_THRESHOLD > (self.jumpOrigin - self.hitbox.position.y) then
            self.flagManager:setFlag("SHORT_HOP")
        end

        if self:canBlock() and self.gamepad:buttonPressed("leftshoulder") then
            self.flagManager:setFlag("BLOCK")
        elseif self.flagManager:isFlagSet("BLOCKING") and not self.flagManager:isFlagSet("HITSTUN") and not self.gamepad:buttonPressed("leftshoulder") then
            self.flagManager:resetFlag("BLOCK")
        end

        if self:canTaunt() and self.gamepad:axisMoved("triggerright", 0.9, 4) and self.gamepad:axisMoved("triggerleft", 0.9, 4) then
            self.flagManager:setFlag("TAUNT")
        elseif self.flagManager:isFlagSet("TAUNTING") and not (self.gamepad:axisMoved("triggerright", 0.9, 4) and self.gamepad:axisMoved("triggerleft", 0.9, 4)) then
            self.flagManager:resetFlag("TAUNT")
        end
    end

    if not self.hitbox:wasTouching(hitbox.BOTTOM) and self.hitbox:isTouching(hitbox.BOTTOM) then
        love.audio.play(landingSounds[1])
    end

    entity.Entity.update (self)
end

function Player:draw()
    if self:canMove () then
        if not self.hitbox:isTouching (hitbox.BOTTOM) then
            if self.hitbox.speed.y > 0 then
                self.animation:setAnimation ("FALL")
            else
                self.animation:setAnimation ("JUMP")
            end
        else
            if self.flagManager:isOneFlagSet({"MOVING_LEFT", "MOVING_RIGHT"}) then
                self.animation:setAnimation ("MOVING")
            else
                self.animation:setAnimation ("IDLE")
            end
        end
    elseif self.flagManager:isFlagSet ("DASH") then
        self.animation:setAnimation ("DASH")
    elseif self.flagManager:isFlagSet ("BLOCK") then
        self.animation:setAnimation ("BLOCK")

    elseif self.flagManager:isFlagSet ("ATTACK_CHARGE_SETUP") then
        if self.flagManager:isOneFlagSet ({"ATTACK_LEFT", "ATTACK_RIGHT"}) then
            self.animation:setAnimation ("ATTACK_CHARGE_HOR_0")
        elseif self.flagManager:isFlagSet ("ATTACK_UP") then
            self.animation:setAnimation ("ATTACK_CHARGE_UP_0")
        else
            self.animation:setAnimation ("ATTACK_CHARGE_DOWN_0")
        end


    elseif self.flagManager:isFlagSet ("ATTACK_CHARGING") then
        if self.flagManager:isOneFlagSet ({"ATTACK_LEFT", "ATTACK_RIGHT"}) then
            if self.chargeTime >= MAX_CHARGE_TIME then
                self.animation:setAnimation ("ATTACK_CHARGE_HOR_2")
            elseif self.chargeTime >= MAX_CHARGE_TIME / 2 then
                self.animation:setAnimation ("ATTACK_CHARGE_HOR_1")
            else
                self.animation:setAnimation ("ATTACK_CHARGE_HOR_0")
            end
        elseif self.flagManager:isFlagSet ("ATTACK_UP") then
            if self.chargeTime >= MAX_CHARGE_TIME then
                self.animation:setAnimation ("ATTACK_CHARGE_UP_2")
            elseif self.chargeTime >= MAX_CHARGE_TIME / 2 then
                self.animation:setAnimation ("ATTACK_CHARGE_UP_1")
            else
                self.animation:setAnimation ("ATTACK_CHARGE_UP_0")
            end
        else
            if self.chargeTime >= MAX_CHARGE_TIME then
                self.animation:setAnimation ("ATTACK_CHARGE_DOWN_2")
            elseif self.chargeTime >= MAX_CHARGE_TIME / 2 then
                self.animation:setAnimation ("ATTACK_CHARGE_DOWN_1")
            else
                self.animation:setAnimation ("ATTACK_CHARGE_DOWN_0")
            end
        end

    elseif self.flagManager:isFlagSet ("ATTACK_SETUP") then
        if self.flagManager:isOneFlagSet ({"ATTACK_LEFT", "ATTACK_RIGHT"}) then
            if self.chargeTime >= MAX_CHARGE_TIME then
                self.animation:setAnimation ("ATTACK_SETUP_HOR_2")
            elseif self.chargeTime >= MAX_CHARGE_TIME / 2 then
                self.animation:setAnimation ("ATTACK_SETUP_HOR_1")
            else
                self.animation:setAnimation ("ATTACK_SETUP_HOR_0")
            end
        elseif self.flagManager:isFlagSet ("ATTACK_UP") then
            if self.chargeTime >= MAX_CHARGE_TIME then
                self.animation:setAnimation ("ATTACK_SETUP_UP_2")
            elseif self.chargeTime >= MAX_CHARGE_TIME / 2 then
                self.animation:setAnimation ("ATTACK_SETUP_UP_1")
            else
                self.animation:setAnimation ("ATTACK_SETUP_UP_0")
            end
        else
            if self.chargeTime >= MAX_CHARGE_TIME then
                self.animation:setAnimation ("ATTACK_SETUP_DOWN_2")
            elseif self.chargeTime >= MAX_CHARGE_TIME / 2 then
                self.animation:setAnimation ("ATTACK_SETUP_DOWN_1")
            else
                self.animation:setAnimation ("ATTACK_SETUP_DOWN_0")
            end
        end

    elseif self.flagManager:isFlagSet ("ATTACKING_METEOR") then
        if self.chargeTime >= MAX_CHARGE_TIME then
            self.animation:setAnimation ("ATTACK_DOWN_LOOP_2")
        elseif self.chargeTime >= MAX_CHARGE_TIME / 2 then
            self.animation:setAnimation ("ATTACK_DOWN_LOOP_1")
        end
    elseif self.flagManager:isFlagSet ("ATTACKING") then

        if self.flagManager:isOneFlagSet ({"ATTACK_LEFT", "ATTACK_RIGHT"}) then
            if self.chargeTime >= MAX_CHARGE_TIME then
                self.animation:setAnimation ("ATTACK_HOR_2")
            elseif self.chargeTime >= MAX_CHARGE_TIME / 2 then
                self.animation:setAnimation ("ATTACK_HOR_1")
            else
                self.animation:setAnimation ("ATTACK_HOR_0")
            end
        elseif self.flagManager:isFlagSet ("ATTACK_UP") then
            if self.chargeTime >= MAX_CHARGE_TIME then
                self.animation:setAnimation ("ATTACK_UP_2")
            elseif self.chargeTime >= MAX_CHARGE_TIME / 2 then
                self.animation:setAnimation ("ATTACK_UP_1")
            else
                self.animation:setAnimation ("ATTACK_UP_0")
            end
        elseif self.flagManager:isFlagSet ("ATTACK_DOWN") then
            if self.chargeTime >= MAX_CHARGE_TIME then
                self.animation:setAnimation ("ATTACK_DOWN_GROUND")
            elseif self.chargeTime >= MAX_CHARGE_TIME / 2 then
                self.animation:setAnimation ("ATTACK_DOWN_GROUND")
            else
                self.animation:setAnimation ("ATTACK_DOWN_0")
            end
        end

    elseif self.flagManager:isFlagSet ("HITSTUN") then
        self.animation:setAnimation ("LAUNCHED")
    elseif self.flagManager:isFlagSet ("TAUNT") then
        if self.flagManager:isFlagSet ("TAUNTING") then
            self.animation:setAnimation ("TAUNT")
        else
            self.animation:setAnimation ("TAUNT_SETUP")
        end
    end

    entity.Entity.draw (self)
end

return player

local math = math
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
local METEOR_SPEED_1 = 2 * JUMP_SPEED
local METEOR_SPEED_2 = 3 * JUMP_SPEED
local ANIMATION_OFFSET_RIGHT_X = -60
local ANIMATION_OFFSET_LEFT_X = 110
local ANIMATION_OFFSET_Y = -123
local BLOCK_DRAG = 1

Player = utils.inheritsFrom (entity.Entity, function (self, gamepad, character)
    entity.Entity.__constructor (self)

    -- Properties
    self.facing = "left"
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

            self.flagManager:setFlag("HITSTUN")
        end
    end 
    self.hitbox.score = function ()
        self.points = self.points + 1
    end

    self.graphic = self:addComponent(shape.rectangle (WIDTH, HEIGHT, {255, 0, 0, 255}))
    self.graphic:setReference (self.hitbox.position)

    self.animation = self:addComponent(animation.Animation(self.framedata.imgFile, self.framedata.frames, self.framedata.animations))
    self.animation.x = ANIMATION_OFFSET_RIGHT_X
    self.animation.y = ANIMATION_OFFSET_Y
    self.animation:setReference (self.hitbox.position)
    self.animation:setAnimation ("IDLE")

    self.timer = self:addComponent(timer.Timer())

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

    self.flagManager:addFlag("INVINCIBLE",
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

    local function prepareAttack ()
        self.flagManager:resetFlag("MOVING_LEFT")
        self.flagManager:resetFlag("MOVING_RIGHT")

        self.hitbox.speed.x = 0
        self.hitbox.speed.y = JUMP_SPEED / 10
        self.hitbox.acceleration.y = 0
        self.chargeTime = 0
        self.flagManager:setFlag("ATTACK_SETUP")
        self.flagManager:setFlag("ATTACK_CHARGING")
    end

    local function placeAttack (attackComponent)
        self.attack = self:addComponent(attackComponent)
        -- self.attackGraphic = self:addComponent(attackComponent.graphic)
    end

    local function removeAttack ()
        if self.attack then
            self:removeComponent(self.attack)
            -- self:removeComponent(self.attackGraphic)
            self.attack = nil
            -- self.attackGraphic = nil
        end
    end

    local function endAttack (dir)
        self.flagManager:setFlag("ATTACK_ACCOMODATION")
        self.timer:start(self.attack.accomodation, function ()
            self.flagManager:resetFlag("ATTACK_" .. dir)
        end)
        self.flagManager:resetFlag("ATTACK_SETUP")
        removeAttack ()
    end

    local function interruptAttack ()
        self.timer:clear (self.timers["endAttack"])
        self.timer:clear (self.timers["prepareAttack"])
        self.hitbox.acceleration.y = GRAVITY
        self.hitbox.maxSpeed.y = JUMP_SPEED
        self.flagManager:resetFlag("ATTACK_SETUP")
        self.flagManager:resetFlag("ATTACK_CHARGING")
        self.flagManager:resetFlag("ATTACK_ACCOMODATION")
        removeAttack()
    end

    local function startAttack (dir)
        self.timers["endAttack"] = self.timer:start(self.attack.duration, 
        function ()
            endAttack (dir)
        end)
        self.flagManager:resetFlag("ATTACK_SETUP")
        self.flagManager:resetFlag("ATTACK_CHARGING")
    end

    local function startMeteorAttack (speed)
        self.hitbox.maxSpeed.y = speed
        self.hitbox.speed.y = speed
        self.flagManager:resetFlag("ATTACK_SETUP")
        self.flagManager:resetFlag("ATTACK_CHARGING")
        self.flagManager:setFlag("ATTACK_METEOR")
    end

    self.flagManager:addFlag(
    "ATTACK_LEFT",
    function ()
        if self.flagManager:isFlagSet("ATTACK_CHARGING") then
            if self.gamepad:buttonPressed("x") then 
                self.chargeTime = self.chargeTime + 1
                if self.chargeTime >= 3 * MAX_CHARGE_TIME / 2 then
                    placeAttack (self.attackData.left_2)
                    startAttack ("LEFT")
                end
            elseif self.chargeTime >= MAX_CHARGE_TIME then
                placeAttack (self.attackData.left_2)
                startAttack ("LEFT")
            elseif self.chargeTime >= MAX_CHARGE_TIME / 2 then
                placeAttack (self.attackData.left_1)
                startAttack ("LEFT")
            else
                if self.chargeTime >= self.attackData.left_0.setup then
                    placeAttack (self.attackData.left_0)
                    startAttack ("LEFT")
                else
                    self.flagManager:resetFlag("ATTACK_CHARGING")
                    self.timers["prepareAttack"] = self.timer:start(self.attackData.left_0.setup - self.chargeTime,
                    function ()
                        placeAttack (self.attackData.left_0)
                        startAttack ("LEFT")
                    end)
                end
            end
        end
    end,
    function ()
        self.facing = "left"
        self.animation.scale.x = -1
        self.animation.x = ANIMATION_OFFSET_LEFT_X
        prepareAttack()
    end,
    interruptAttack)

    self.flagManager:addFlag(
    "ATTACK_RIGHT",
    function ()
        if self.flagManager:isFlagSet("ATTACK_CHARGING") then
            if self.gamepad:buttonPressed("b") then 
                self.chargeTime = self.chargeTime + 1
                if self.chargeTime >= 3 * MAX_CHARGE_TIME / 2 then
                    placeAttack (self.attackData.right_2)
                    startAttack ("RIGHT")
                end
            elseif self.chargeTime >= MAX_CHARGE_TIME then
                placeAttack (self.attackData.right_2)
                startAttack ("RIGHT")
            elseif self.chargeTime >= MAX_CHARGE_TIME / 2 then
                placeAttack (self.attackData.right_1)
                startAttack ("RIGHT")
            else
                if self.chargeTime >= self.attackData.right_0.setup then
                    placeAttack (self.attackData.right_0)
                    startAttack ("RIGHT")
                else
                    self.flagManager:resetFlag("ATTACK_CHARGING")
                    self.timers["prepareAttack"] = self.timer:start(self.attackData.right_0.setup - self.chargeTime,
                    function ()
                        placeAttack (self.attackData.right_0)
                        startAttack ("RIGHT")
                    end)
                end
            end
        end
    end,
    function ()
        self.facing = "right"
        self.animation.scale.x = 1
        self.animation.x = ANIMATION_OFFSET_RIGHT_X
        prepareAttack()
    end,
    interruptAttack)

    self.flagManager:addFlag(
    "ATTACK_UP",
    function ()
        if self.flagManager:isFlagSet("ATTACK_CHARGING") then
            if self.gamepad:buttonPressed("y") then 
                self.chargeTime = self.chargeTime + 1
                if self.chargeTime >= 3 * MAX_CHARGE_TIME / 2 then
                    placeAttack (self.attackData.up_2)
                    startAttack ("UP")
                end
            elseif self.chargeTime >= MAX_CHARGE_TIME then
                placeAttack (self.attackData.up_2)
                startAttack ("UP")
            elseif self.chargeTime >= MAX_CHARGE_TIME / 2 then
                placeAttack (self.attackData.up_1)
                startAttack ("UP")
            else
                if self.chargeTime >= self.attackData.up_0.setup then
                    placeAttack (self.attackData.up_0)
                    startAttack ("UP")
                else
                    self.flagManager:resetFlag("ATTACK_CHARGING")
                    self.timers["prepareAttack"] = self.timer:start(self.attackData.up_0.setup - self.chargeTime,
                    function ()
                        placeAttack (self.attackData.up_0)
                        startAttack ("UP")
                    end)
                end
            end
        end
    end,
    prepareAttack,
    interruptAttack)

    self.flagManager:addFlag(
    "ATTACK_DOWN",
    function ()
        if self.flagManager:isFlagSet("ATTACK_CHARGING") then
            if self.gamepad:buttonPressed("a") then 
                self.chargeTime = self.chargeTime + 1
                if self.chargeTime >= 3 * MAX_CHARGE_TIME / 2 then
                    placeAttack (self.attackData.down_2)
                    if not self.hitbox:isTouching (hitbox.BOTTOM) then
                        startMeteorAttack (METEOR_SPEED_2)
                    else 
                        startAttack("DOWN")
                    end
                end
            elseif self.chargeTime >= MAX_CHARGE_TIME then
                placeAttack (self.attackData.down_2)
                if not self.hitbox:isTouching (hitbox.BOTTOM) then
                    startMeteorAttack (METEOR_SPEED_2)
                else 
                    startAttack("DOWN")
                end
            elseif self.chargeTime >= MAX_CHARGE_TIME / 2 then
                placeAttack (self.attackData.down_1)
                if not self.hitbox:isTouching (hitbox.BOTTOM) then
                    startMeteorAttack (METEOR_SPEED_1)
                else 
                    startAttack("DOWN")
                end
            else
                if self.chargeTime >= self.attackData.down_0.setup then
                    placeAttack (self.attackData.down_0)
                    startAttack ("DOWN")
                else
                    self.flagManager:resetFlag("ATTACK_CHARGING")
                    self.timers["prepareAttack"] = self.timer:start(self.attackData.down_0.setup - self.chargeTime,
                    function ()
                        placeAttack (self.attackData.down_0)
                        startAttack ("DOWN")
                    end)
                end
            end
        elseif self.flagManager:isFlagSet("ATTACK_METEOR") and (not self.hitbox:wasTouching(hitbox.BOTTOM) and self.hitbox:isTouching (hitbox.BOTTOM)) then
            self.flagManager:resetFlag("ATTACK_METEOR")
            startAttack("DOWN")
        end
    end,
    prepareAttack,
    function ()
        interruptAttack()
        self.hitbox.maxSpeed.y = JUMP_SPEED
    end
    )

    self.flagManager:addFlag("ATTACK_SETUP")
    self.flagManager:addFlag("ATTACK_CHARGING")
    self.flagManager:addFlag("ATTACK_METEOR")
    self.flagManager:addFlag("ATTACK_ACCOMODATION")

    self.flagManager:addFlag("HITSTUN",
    function ()
        if not self.hitbox:wasTouching(hitbox.BOTTOM) and self.hitbox:isTouching(hitbox.BOTTOM) then
            self.hitbox.acceleration.x = self.hitbox.speed.x > 0 and -BLOCK_DRAG or BLOCK_DRAG
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

        if not self.hitbox:wasTouching(hitbox.BOTTOM) and self.hitbox:isTouching(hitbox.BOTTOM) then
            if self.hitbox.speed.y > 0 then
                self.hitbox.speed.y = -self.hitbox.speed.y/2
            end
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

    -- self.flagManager:addFlag("TAUNT")
    -- self.flagManager:addFlag("EXPRESSION")
    -- self.flagManager:addFlag("KNOCKBACK")
    self.gamepad = self:addComponent(gamepad)

end)

function Player:canMove()
    return not self.flagManager:isOneFlagSet({"DASH", "BLOCK", "ATTACK_LEFT", "ATTACK_RIGHT", "ATTACK_UP", "ATTACK_DOWN", "HITSTUN"})
end

function Player:canJump()
    return self.hitbox:isTouching(hitbox.BOTTOM) and not self.flagManager:isOneFlagSet({"DASH", "BLOCK", "ATTACK_LEFT", "ATTACK_RIGHT", "ATTACK_UP", "ATTACK_DOWN", "HITSTUN"})
end

function Player:canDoubleJump()
    return not (self.hitbox:isTouching(hitbox.BOTTOM) or self.flagManager:isOneFlagSet({"DOUBLE_JUMP", "DASH", "BLOCK", "ATTACK_LEFT", "ATTACK_RIGHT", "ATTACK_UP", "ATTACK_DOWN", "HITSTUN"}))
end

function Player:canDash()
    return not self.flagManager:isOneFlagSet({"DASH", "DASH_COOLDOWN", "BLOCK", "ATTACK_LEFT", "ATTACK_RIGHT", "ATTACK_UP", "ATTACK_DOWN", "HITSTUN"})
end

function Player:canAttack()
    return not (self.flagManager:isOneFlagSet({"DASH", "BLOCK", "ATTACK_LEFT", "ATTACK_RIGHT", "ATTACK_UP", "ATTACK_DOWN", "HITSTUN"}))
end

function Player:update()
    if self:canMove() then
        if self.gamepad:buttonPressed("dpright") then
            self.flagManager:setFlag("MOVING_RIGHT")
        elseif self.gamepad:buttonPressed("dpleft") then 
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

    if self.flagManager:isOneFlagSet({"JUMP", "DOUBLE_JUMP"}) and  
        not self.flagManager:isFlagSet("FALL") and
        self.gamepad:buttonJustReleased ("a") then
        if SHORT_HOP_THRESHOLD > (self.jumpOrigin - self.hitbox.position.y) then
            self.flagManager:setFlag("SHORT_HOP")
        end
    end

    if self.gamepad:buttonJustPressed("leftshoulder") then
        self.flagManager:setFlag("BLOCK")
    elseif self.flagManager:isFlagSet("BLOCKING") and not self.flagManager:isFlagSet("HITSTUN") and not self.gamepad:buttonPressed("leftshoulder") then
        self.flagManager:resetFlag("BLOCK")
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
        self.animation:setAnimation ("IDLE")
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
    elseif self.flagManager:isOneFlagSet ({"ATTACK_LEFT", "ATTACK_RIGHT"}) then
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
        if self.hitbox:isTouching(hitbox.BOTTOM) then
            if self.chargeTime >= MAX_CHARGE_TIME then
                self.animation:setAnimation ("ATTACK_DOWN_2")
            elseif self.chargeTime >= MAX_CHARGE_TIME / 2 then
                self.animation:setAnimation ("ATTACK_DOWN_1")
            else
                self.animation:setAnimation ("ATTACK_DOWN_0")
            end
        else
            if self.chargeTime >= MAX_CHARGE_TIME then
                self.animation:setAnimation ("ATTACK_DOWN_FALLING_2")
            elseif self.chargeTime >= MAX_CHARGE_TIME / 2 then
                self.animation:setAnimation ("ATTACK_DOWN_FALLING_1")
            else
                self.animation:setAnimation ("ATTACK_DOWN_0")
            end

        end
    elseif self.flagManager:isFlagSet ("HITSTUN") then
        self.animation:setAnimation ("LAUNCHED")
    end

    entity.Entity.draw (self)
end

return player

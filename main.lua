local gamepad = require "gamepad"
local utils = require "utils"
local player = require "player"
local box = require "box"
local hitbox = require "hitbox"
local entity = require "entity"
local timer = require "timer"
local constants = require "constants"
local image = require "image"

local entityList = {}
local entityId = 1

function love.load ()
    -- Screen size
    love.window.setMode(constants.screenWidth, constants.screenHeight)
    
    bg = addEntity (entity.Entity())
    bg:addComponent (image.Image("onemanband2.jpg"))

    leftBlock = addEntity(box.Box(50,570,200,100,{78, 51, 26, 255}))
    rightBlock = addEntity(box.Box(1030,570,200,100,{78, 51, 26, 255}))

    leftPlatform = addEntity(box.Box(50,420,70,150,{78, 51, 26, 255}))
    rightPlatform = addEntity(box.Box(1160,420,70,150,{78, 51, 26, 255}))

    spotPlatform = addEntity(box.Box(440, 340, 400, 30,{78, 51, 26, 255}))

    players = {}

    for i, joystick in ipairs(love.joystick.getJoysticks()) do
        if joystick:isGamepad() then
            table.insert(players, addEntity(player.Player(gamepad.Gamepad(20, joystick:getID()), "Player_" .. i)))
        end
    end

    spotlight = entity.Entity ()
    spotlightHitbox = spotlight:addComponent (hitbox.Hitbox (150, 100, "spot"))
    spotlightHitbox.position.x = 565
    spotlightHitbox.position.y = 240

    spotlightGraphic = spotlight:addComponent (image.Image("spotlight.png"))
    spotlightGraphic:setReference (spotlightHitbox.position)
    spotlightGraphic.x = - (spotlightGraphic.img:getWidth() - spotlightHitbox.width) / 2 + 65
    spotlightGraphic.y = - spotlightGraphic.img:getHeight() + spotlightHitbox.height + 30

    addEntity (spotlight)

    upWall = addEntity(box.Box(0,0,1280,50))
    leftWall = addEntity(box.Box(0,50,50,670))
    downWall = addEntity(box.Box(50,670,1230,50))
    rightWall = addEntity(box.Box(1230,50,50,620))

    timerEntity = addEntity (entity.Entity())
    timerEntity.timer = timerEntity:addComponent(timer.Timer())

    -- timerEntity.timer:start(99 * constants.framerate, function ()
       -- running = false
    -- end)

end

function addEntity (entity)
    entityList[entityId] = entity
    entity.entityId = entityId

    entityId = entityId + 1
    return entity
end

function removeEntity (entity)
    entityList[entity.entityId] = nil
end

function love.run()
    if love.math then
        love.math.setRandomSeed(os.time())
    end

    if love.event then
        love.event.pump()
    end

    if love.load then love.load(arg) end

    -- We don't want the first frame's dt to include time taken by love.load.
    if love.timer then love.timer.step() end

    local frameDuration = 1 / constants.framerate

    local curentFrameTime = 0
    local elapsedTime = 0

    running = true;

    -- Main loop time.
    while true do
        -- Update dt, as we'll be passing it to update
        if love.timer then
            currentFrameTime = love.timer.getTime()
        end

        -- Process events.
        if love.event then
            love.event.pump()
            for e,a,b,c,d in love.event.poll() do
                if e == "quit" then
                    if not love.quit or not love.quit() then
                        if love.audio then
                            love.audio.stop()
                        end
                        return
                    end
                end
                love.handlers[e](a,b,c,d)
            end
        end

        -- Call update and draw
        if running and love.update then love.update() end -- will pass 0 if love.timer is disabled

        if love.window and love.graphics and love.window.isCreated() then
            love.graphics.clear()
            love.graphics.origin()
            if love.draw then love.draw() end
            love.graphics.present()
        end

        elapsedTime = (love.timer.getTime() - currentFrameTime)
        if love.timer and elapsedTime > 0 then love.timer.sleep(frameDuration - elapsedTime) end
    end
end

function love.update (dt)
    for id, entity in pairs(entityList) do
        entity:update(dt)
    end
    
    hitbox.collide ("player", "wall")
    hitbox.overlap ("player", "attack", 
        function (a, b)
            if a.parent ~= b.parent then
                a.hitCallback (b)
            end
        end)
    hitbox.overlap ("player", "spot",
        function (a, b)
            a.score ()
        end)
end

function love.draw ()
    for id, entity in pairs(entityList) do
        entity:draw()
    end

    if not running then
        for i = 1, #players do
            love.graphics.setNewFont(30)
            love.graphics.setColor(0, 255, 0, 255)
            love.graphics.print ("Player " .. i .. ": " .. players[i].points, 100, 100 + 50 * i)
        end
    end
end

function love.gamepadpressed (joystick, button)
    for i, player in ipairs(players) do
        if joystick:getID() == player.gamepad.id then
            player.gamepad:updateButton (button, true)
        end
    end
end

function love.gamepadreleased (joystick, button)
    for i, player in ipairs(players) do
        if joystick:getID() == player.gamepad.id then
            player.gamepad:updateButton (button, false)
        end
    end
end

function love.gamepadaxis (joystick, axis)
    for i, player in ipairs(players) do
        if joystick:getID() == player.gamepad.id then
            player.gamepad:updateAxis (axis, joystick:getGamepadAxis(axis))
        end
    end
end

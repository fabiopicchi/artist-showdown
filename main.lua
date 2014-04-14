local menuContext = require "menuContext"
local constants = require "constants"
local gamepad = require "gamepad"

function love.load ()
    -- Screen size
    love.audio.setVolume(0)
    love.window.setMode(constants.screenWidth, constants.screenHeight)
    setContext(menuContext.MenuContext())
end

function love.run()
    if love.math then
        love.math.setRandomSeed(os.time())
    end

    if love.event then
        love.event.pump()
    end

    gamepads = {}
    for i, joystick in ipairs(love.joystick.getJoysticks()) do
        if joystick:isGamepad() then
            table.insert(gamepads, gamepad.Gamepad(20, joystick:getID()))
        end
    end

    if love.load then love.load(arg) end

    -- We don't want the first frame's dt to include time taken by love.load.
    if love.timer then love.timer.step() end

    local frameDuration = 1 / constants.framerate

    local curentFrameTime = 0
    local elapsedTime = 0

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
        if love.update then love.update() end -- will pass 0 if love.timer is disabled
        
        for i, gamepad in ipairs(gamepads) do
            gamepad:update()
        end

        if currentContext.endGame then
            break
        end

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

function love.update ()
    if currentContext.nextContext then
        setContext (currentContext.nextContext)
    end

    currentContext:update()
end

function love.draw ()
    currentContext:draw()
end

function love.gamepadpressed (joystick, button)
    for i, gamepad in ipairs(gamepads) do
        if joystick:getID() == gamepad.id then
            gamepad:updateButton (button, true)
        end
    end
end

function love.gamepadreleased (joystick, button)
    for i, gamepad in ipairs(gamepads) do
        if joystick:getID() == gamepad.id then
            gamepad:updateButton (button, false)
        end
    end
end

function love.gamepadaxis (joystick, axis)
    for i, gamepad in ipairs(gamepads) do
        if joystick:getID() == gamepad.id then
            gamepad:updateAxis (axis, joystick:getGamepadAxis(axis))
        end
    end
end

function setContext(context)
    currentContext = context
    currentContext.gamepads = gamepads
    context:init()
end

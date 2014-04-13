local math = math
local pairs = pairs
local love = love

local gameContext = require "gameContext"
local entity = require "entity"
local utils = require "utils"
local context = require "context"
local menu = require "menu"
local listMenu = require "listMenu"
local circularMenu = require "circularMenu"
local image = require "image"
local flagManager = require "flagManager"
local timer = require "timer"

local menuContext = {}
setfenv (1, menuContext)

MenuContext = utils.inheritsFrom (context.Context, function (self)
    context.Context.__constructor(self)
    
    bg = self:addEntity (entity.Entity())
    bg:addComponent (image.Image("assets/images/menu/bg_main.png"))

    self.flagManagerEntity = self:addEntity(entity.Entity())

    self.flagManager = self.flagManagerEntity:addComponent(flagManager.FlagManager())
    self.flagManager:addFlag("PRESS_START")

    self.timerEntity = self:addEntity(entity.Entity())
    self.timer = self.timerEntity:addComponent(timer.Timer())

    self.flagManager:addFlag(
        "MAIN_MENU",
        function ()
            if self.gamepad:buttonJustPressed("b") then
                self.flagManager:resetFlag("MAIN_MENU")
                self.flagManager:setFlag("PRESS_START")
                self.gamepad = nil
                love.audio.play(self.back)
            end
        end,
        function ()
            self.circularMenu:selectOption(1)
            self.timer:start (1, function ()
                self:addEntity(self.circularMenu)
            end)
        end,
        function ()
            self:removeEntity(self.circularMenu)
        end
    )

    self.flagManager:addFlag(
        "PLAY_MENU",
        function ()
            if self.gamepad:buttonJustPressed("b") then
                self.flagManager:resetFlag("PLAY_MENU")
                self.flagManager:setFlag("MAIN_MENU")
                love.audio.play(self.back)
            end
        end,
        function ()
            self.listMenu.menu:gotoOption(1)
            self.timer:start (1, function ()
                self:addEntity(self.listMenu)
            end)
        end,
        function ()
            self:removeEntity(self.listMenu)
        end
    )

    self.circularMenu = circularMenu.CircularMenu (
        menu.Menu ({
            function ()
                self.flagManager:resetFlag("MAIN_MENU")
                self.flagManager:setFlag("PLAY_MENU")
                love.audio.play(self.select)
            end,
            function ()

            end,
            function ()

            end,
            function ()

            end
        }),
        {
            image.Image ("assets/images/menu/play.png"),
            image.Image ("assets/images/menu/options.png"),
            image.Image ("assets/images/menu/credits.png"),
            image.Image ("assets/images/menu/exit.png")
        },
        {x = 640, y = 560}, 200, math.pi / 12)

    self.listMenu = listMenu.ListMenu (
        menu.Menu ({
            function ()
                love.audio.play(self.select)
                self.nextContext = gameContext.GameContext (2) 
            end,
            function ()
                love.audio.play(self.select)
                self.nextContext = gameContext.GameContext (3) 
            end,
            function ()
                love.audio.play(self.select)
                self.nextContext = gameContext.GameContext (4) 
            end
        }),
        {
            image.Image ("assets/images/menu/2p.png"),
            image.Image ("assets/images/menu/3p.png"),
            image.Image ("assets/images/menu/4p.png"),
        },
        image.Image("assets/images/menu/bolinha.png"),
        {x = 640, y = 460}, 10, 10)

    self.flagManager:setFlag("PRESS_START")

    self.bgMusic = love.audio.newSource("assets/sound/songs/Musica_generica.mp3")
    self.bgMusic:setLooping(true)
    love.audio.play(self.bgMusic)

    self.back = love.audio.newSource("assets/sound/sfx/menu_back.ogg")
    self.select = love.audio.newSource("assets/sound/sfx/menu_accept.ogg")
end)

function MenuContext:update ()
    if self.flagManager:isFlagSet("PRESS_START") then
        for i, gamepad in pairs(self.gamepads) do
            if gamepad:buttonJustPressed ("start") then
                self.gamepad = gamepad

                self.circularMenu.gamepad = self.gamepad
                self.listMenu.gamepad = self.gamepad

                self.flagManager:setFlag("MAIN_MENU")
                self.flagManager:resetFlag("PRESS_START")

                love.audio.play(self.select)
                break
            end
        end
    end

    context.Context.update(self)
end

return menuContext

local utils = require "utils"
local hitbox = require "hitbox"
local context = require "context"
local image = require "image"
local box = require "box"
local entity = require "entity"
local player = require "player"
local love = love

local gameContext = {}
setfenv (1, gameContext)

GameContext = utils.inheritsFrom (context.Context, function (self, nPlayers)
    context.Context.__constructor(self)
    
    local bg = self:addEntity (entity.Entity())
    bg:addComponent (image.Image("assets/images/levels/onemanband2.jpg"))

    local leftBlock = self:addEntity(box.Box(50,570,200,100,{78, 51, 26, 255}))
    local rightBlock = self:addEntity(box.Box(1030,570,200,100,{78, 51, 26, 255}))

    local leftPlatform = self:addEntity(box.Box(50,420,70,150,{78, 51, 26, 255}))
    local rightPlatform = self:addEntity(box.Box(1160,420,70,150,{78, 51, 26, 255}))

    local spotPlatform = self:addEntity(box.Box(440, 340, 400, 30,{78, 51, 26, 255}))

    self.nPlayers = nPlayers

    local spotlight = entity.Entity ()
    local spotlightHitbox = spotlight:addComponent (hitbox.Hitbox (150, 100, "spot"))
    spotlightHitbox.position.x = 565
    spotlightHitbox.position.y = 240

    local spotlightGraphic = spotlight:addComponent (image.Image("assets/images/levels/spotlight.png"))
    spotlightGraphic:setReference (spotlightHitbox.position)
    spotlightGraphic.x = - (spotlightGraphic.img:getWidth() - spotlightHitbox.width) / 2 + 65
    spotlightGraphic.y = - spotlightGraphic.img:getHeight() + spotlightHitbox.height + 30

    self:addEntity (spotlight)

    local upWall = self:addEntity(box.Box(0,0,1280,50))
    local leftWall = self:addEntity(box.Box(0,50,50,670))
    local downWall = self:addEntity(box.Box(50,670,1230,50))
    local rightWall = self:addEntity(box.Box(1230,50,50,620))

    -- timerEntity = addEntity (entity.Entity())
    -- timerEntity.timer = timerEntity:addComponent(timer.Timer())

    -- timerEntity.timer:start(99 * constants.framerate, function ()
       -- running = false
    -- end)
end)


function GameContext:init()
    self.players = {}

    for i = 1, self.nPlayers do
        self.players = self:addEntity(player.Player(self.gamepads[i], "Player_" .. i))
    end

    love.audio.stop()

    local bgMusic = love.audio.newSource("assets/sound/songs/Polka.mp3")
    bgMusic:setLooping(true)
    love.audio.play(bgMusic)
end

function GameContext:update()
    context.Context.update(self)

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

function GameContext:draw()
    context.Context.draw(self)
end

return gameContext
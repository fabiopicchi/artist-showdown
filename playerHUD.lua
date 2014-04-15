local utils = require "utils"
local entity = require "entity"
local image = require "image"
local particleSystem = require "particleSystem"

local playerHUD = {}
setfenv (1, playerHUD)

local baseImage1 = image.Image("assets/images/ui/p1_base.png")
local baseImage2 = image.Image("assets/images/ui/p2_base.png")
local baseImage3 = image.Image("assets/images/ui/p3_base.png")
local baseImage4 = image.Image("assets/images/ui/p4_base.png")

local coverImage1 = image.Image("assets/images/ui/p1_cover.png")
local coverImage2 = image.Image("assets/images/ui/p2_cover.png")
local coverImage3 = image.Image("assets/images/ui/p3_cover.png")
local coverImage4 = image.Image("assets/images/ui/p4_cover.png")

local lightImage1 = image.Image("assets/images/ui/p1_luz.png")
local lightImage2 = image.Image("assets/images/ui/p2_luz.png")
local lightImage3 = image.Image("assets/images/ui/p3_luz.png")
local lightImage4 = image.Image("assets/images/ui/p4_luz.png")

local hudEmitter1 = particleSystem.ParticleSystem ("assets.particles.particle_hud1", image.Image("assets/particles/ticles_shine.png").img)
local hudEmitter2 = particleSystem.ParticleSystem ("assets.particles.particle_hud2", image.Image("assets/particles/ticles_shine.png").img)
local hudEmitter3 = particleSystem.ParticleSystem ("assets.particles.particle_hud3", image.Image("assets/particles/ticles_shine.png").img)
local hudEmitter4 = particleSystem.ParticleSystem ("assets.particles.particle_hud4", image.Image("assets/particles/ticles_shine.png").img)

hudEmitter1:stop()
hudEmitter2:stop()
hudEmitter3:stop()
hudEmitter4:stop()

local barPosition1 = {x = 99, y = 35}
local barPosition2 = {x = 126, y = 35} 
local barPosition3 = {x = 99, y = 34} 
local barPosition4 = {x = 126, y = 34} 

local initialStarPosition1 = {x = 25, y = 76} 
local initialStarPosition2 = {x = 173, y = 76} 
local initialStarPosition3 = {x = 24, y = -2} 
local initialStarPosition4 = {x = 173, y = -2} 

local starDistance = 10

local starsProgression = {0, 500, 1500, 3000, 5200, 7000, 10000}

local star = image.Image("assets/images/ui/ui_star.png") 

PlayerHUD = utils.inheritsFrom (entity.Entity, function (self, playerId, scoreReference)
    entity.Entity.__constructor(self)
    
    self.scoreReference = scoreReference
    self.stars = 1
    self.lastScore = 0

    if playerId == 1 then
        self.position = {x = 0, y = 20}
        self:addComponent(baseImage1)
        self.bar = self:addComponent(image.Image("assets/images/ui/ui_bar.png"))
        self.bar.x, self.bar.y = barPosition1.x, barPosition1.y
        self:addComponent(coverImage1)
        self.light = self:addComponent(lightImage1)
        self.bar:setReference(self.position)
        baseImage1:setReference(self.position)
        coverImage1:setReference(self.position)
        lightImage1:setReference(self.position)
        self.initialStarPosition = initialStarPosition1
        self.growth = 1

    elseif playerId == 2 then
        self.position = {x = 1056, y = 20}
        self:addComponent(baseImage2)
        self.bar = self:addComponent(image.Image("assets/images/ui/ui_bar.png"))
        self.bar.x, self.bar.y = barPosition2.x, barPosition2.y
        self:addComponent(coverImage2)
        self.light = self:addComponent(lightImage2)
        self.bar:setReference(self.position)
        baseImage2:setReference(self.position)
        coverImage2:setReference(self.position)
        lightImage2:setReference(self.position)
        self.initialStarPosition = initialStarPosition2
        self.growth = -1

    elseif playerId == 3 then
        self.position = {x = 0, y = 600}
        self:addComponent(baseImage3)
        self.bar = self:addComponent(image.Image("assets/images/ui/ui_bar.png"))
        self.bar.x, self.bar.y = barPosition3.x, barPosition3.y
        self:addComponent(coverImage3)
        self.light = self:addComponent(lightImage3)
        self.bar:setReference(self.position)
        baseImage3:setReference(self.position)
        coverImage3:setReference(self.position)
        lightImage3:setReference(self.position)
        self.initialStarPosition = initialStarPosition3
        self.growth = 1

    else
        self.position = {x = 1056, y = 600}
        self:addComponent(baseImage4) 
        self.bar = self:addComponent(image.Image("assets/images/ui/ui_bar.png"))
        self.bar.x, self.bar.y = barPosition4.x, barPosition4.y
        self:addComponent(coverImage4)
        self.light = self:addComponent(lightImage4)
        self.bar:setReference(self.position)
        baseImage4:setReference(self.position)
        coverImage4:setReference(self.position)
        lightImage4:setReference(self.position)
        self.initialStarPosition = initialStarPosition4
        self.growth = -1

    end

    self.light.visible = false
end)

function PlayerHUD:update()
    if self.lastScore ~= self.scoreReference.points then
        self.light.visible = true
    else
        self.light.visible = false
    end
    self.lastScore = self.scoreReference.points

    if self.scoreReference.points >= starsProgression[self.stars + 1] and self.stars + 1 < #starsProgression then
        local star = self:addComponent(image.Image("assets/images/ui/ui_star.png"))
        star.x = self.initialStarPosition.x + (self.stars - 1) * (star.width + starDistance)
        star.y = self.initialStarPosition.y
        star:setReference(self.position)

        self.stars = self.stars + 1
    end

    self.bar.scale.x = (self.scoreReference.points - starsProgression[self.stars]) / (starsProgression[self.stars + 1] - starsProgression[self.stars]) * self.growth 
end

return playerHUD

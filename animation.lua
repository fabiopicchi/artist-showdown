local utils = require "utils"
local referrer = require "referrer"
local constants = require "constants"
local love = love

local animation = {}
setfenv(1, animation)

local animationFramerate = 15

Animation = utils.inheritsFrom (referrer.Referrer, function (self, imgFile, frames, animations)
    referrer.Referrer.__constructor (self)
    
    self.image = love.graphics.newImage(imgFile)
    self.frames = frames
    self.animations = animations
    self.currentAnimationId = nil
    self.currentAnimation = nil
    self.frameCount = 0
    self.currentFrame = 1
    self.animationComplete = false
    self.scale = {x = 1, y = 1}
    self.rotation = 0
    self.reverse = false
end)

function Animation:setAnimation (id, callbackComplete)
    if self.currentAnimationId ~= id then
        self.currentAnimationId = id
        self.currentAnimation = self.animations[id]
        self.currentAnimation.frameDuration = constants.framerate / animationFramerate
        self.frameCount = 0
        self.currentFrame = self.currentAnimation[1]
        self.animationComplete = false
        self.animationCompleteCallback = callbackComplete
        self.reverse = false
    end
end

function Animation:update ()
    if self.currentAnimation and not self.animationComplete then
        self.frameCount = self.frameCount + 1
        if self.frameCount >= self.currentAnimation.frameDuration then
            self.frameCount = 0
            if (not self.reverse and self.currentFrame >= self.currentAnimation[2]) or (self.reverse and self.currentFrame <= self.currentAnimation[1]) then
                if self.currentAnimation[3] == "loop" then
                    self.currentFrame = self.currentAnimation [1]
                elseif self.currentAnimation[3] == "backnforth" then
                    self.reverse = not self.reverse
                    if not self.reverse then
                        self.currentFrame = self.currentFrame + 1
                    else
                        self.currentFrame = self.currentFrame - 1
                    end
                else
                    self.animationComplete = true
                    if self.animationCompleteCallback then self.animationCompleteCallback() end
                end
            else
                if not self.reverse then
                    self.currentFrame = self.currentFrame + 1
                else
                    self.currentFrame = self.currentFrame - 1
                end
            end
        end
    end
end

function Animation:draw ()
    love.graphics.reset ()
    love.graphics.draw (self.image, self.frames[self.currentFrame], self.reference.x + self.x, self.reference.y + self.y, self.rotation, self.scale.x, self.scale.y)
end

return animation

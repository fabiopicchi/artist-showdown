local love = love
local require = require
local table = table
local pairs = pairs
local math = math
local string = string
local unpack = unpack

local constants = require "constants"
local utils = require "utils"
local referrer = require "referrer"

local particleSystem = {}
setfenv (1, particleSystem)

-- Particle system generator and loader (SPERM) by adnzzzzZ
-- Love2D forum thread: https://love2d.org/forums/viewtopic.php?t=76986&hilit=particles&sid=c36964243bc61fa6c261fbd645f27adf
local function getPS(name, image)
    local ps_data = require(name)
    local particle_settings = {}
    particle_settings["colors"] = {}
    particle_settings["sizes"] = {}
    for k, v in pairs(ps_data) do
        if k == "colors" then
            local j = 1
            for i = 1, #v , 4 do
                local color = {v[i], v[i+1], v[i+2], v[i+3]}
                particle_settings["colors"][j] = color
                j = j + 1
            end
        elseif k == "sizes" then
            for i = 1, #v do particle_settings["sizes"][i] = v[i] end
        else particle_settings[k] = v end
    end
    local ps = love.graphics.newParticleSystem(image, particle_settings["buffer_size"])
    ps:setAreaSpread(string.lower(particle_settings["area_spread_distribution"]), particle_settings["area_spread_dx"] or 0 , particle_settings["area_spread_dy"] or 0)
    ps:setBufferSize(particle_settings["buffer_size"] or 1)
    local colors = {}
    for i = 1, 8 do
        if particle_settings["colors"][i][1] ~= 0 or particle_settings["colors"][i][2] ~= 0 or particle_settings["colors"][i][3] ~= 0 or particle_settings["colors"][i][4] ~= 0 then
            table.insert(colors, particle_settings["colors"][i][1] or 0)
            table.insert(colors, particle_settings["colors"][i][2] or 0)
            table.insert(colors, particle_settings["colors"][i][3] or 0)
            table.insert(colors, particle_settings["colors"][i][4] or 0)
        end
    end
    ps:setColors(unpack(colors))
    ps:setColors(unpack(colors))
    ps:setDirection(math.rad(particle_settings["direction"] or 0))
    ps:setEmissionRate(particle_settings["emission_rate"] or 0)
    ps:setEmitterLifetime(particle_settings["emitter_lifetime"] or 0)
    ps:setInsertMode(string.lower(particle_settings["insert_mode"]))
    ps:setLinearAcceleration(particle_settings["linear_acceleration_xmin"] or 0, particle_settings["linear_acceleration_ymin"] or 0,
    particle_settings["linear_acceleration_xmax"] or 0, particle_settings["linear_acceleration_ymax"] or 0)
    if particle_settings["offsetx"] ~= 0 or particle_settings["offsety"] ~= 0 then
        ps:setOffset(particle_settings["offsetx"], particle_settings["offsety"])
    end
    ps:setParticleLifetime(particle_settings["plifetime_min"] or 0, particle_settings["plifetime_max"] or 0)
    ps:setRadialAcceleration(particle_settings["radialacc_min"] or 0, particle_settings["radialacc_max"] or 0)
    ps:setRotation(math.rad(particle_settings["rotation_min"] or 0), math.rad(particle_settings["rotation_max"] or 0))
    ps:setSizeVariation(particle_settings["size_variation"] or 0)
    local sizes = {}
    local sizes_i = 1
    for i = 1, 8 do
        if particle_settings["sizes"][i] == 0 then
            if i < 8 and particle_settings["sizes"][i+1] == 0 then
                sizes_i = i
                break
            end
        end
    end
    if sizes_i > 1 then
        for i = 1, sizes_i do table.insert(sizes, particle_settings["sizes"][i] or 0) end
        ps:setSizes(unpack(sizes))
    end
    ps:setSpeed(particle_settings["speed_min"] or 0, particle_settings["speed_max"] or 0)
    ps:setSpin(math.rad(particle_settings["spin_min"] or 0), math.rad(particle_settings["spin_max"] or 0))
    ps:setSpinVariation(particle_settings["spin_variation"] or 0)
    ps:setSpread(math.rad(particle_settings["spread"] or 0))
    ps:setTangentialAcceleration(particle_settings["tangential_acceleration_min"] or 0, particle_settings["tangential_acceleration_max"] or 0)
    return ps
end

ParticleSystem = utils.inheritsFrom(referrer.Referrer, function (self, settings, image)
    referrer.Referrer.__constructor(self)
    self:setReference ({x = 640, y = 360})

    self.ps = getPS(settings, image)
    self.ps:start()
end)

function ParticleSystem:added(parent)
    self.parent = parent
end

function ParticleSystem:update()
    self.ps:update(1 / constants.framerate)
end

function ParticleSystem:start()
    self.ps:start()
end

function ParticleSystem:stop()
    self.ps:stop()
end

function ParticleSystem:draw()
    love.graphics.draw(self.ps, self.reference.x + self.x, self.reference.y + self.y)
end

return particleSystem

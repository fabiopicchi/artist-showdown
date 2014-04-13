local utils = require "utils"
local attack = require "attack"

local attackData = {}
setfenv (1, attackData)

AttackData = utils.defineStruct (function ()
    return {

        left = attack.Attack({
            [0] = attack.AttackHitbox (
            60,                         -- width
            40,                         -- height
            {x = -15, y = -5},          -- knockback speed
            {x = -60, y = -20},         -- offset position from center
            6,                          -- setup time in frames
            6,                          -- hitbox duration in seconds
            6),                         -- accomodation in frames


            [1] = attack.AttackHitbox (
            70,                         -- width
            65,                         -- height
            {x = -23, y = -10},         -- knockback speed
            {x = -70, y = -20},         -- offset position from center
            6,                          -- setup time in frames
            6,                          -- hitbox duration in seconds
            6),                         -- accomodation in frames


            [2] = attack.AttackHitbox (
            80,                         -- width
            100,                        -- height
            {x = -33, y = -16},         -- knockback speed
            {x = -80, y = -20},         -- offset position from center
            6,                          -- setup time in frames
            6,                          -- hitbox duration in seconds
            6)                          -- accomodation in frames
        }, "LEFT", "x", 4),

        right = attack.Attack({
            [0] = attack.AttackHitbox (
            60,                         -- width
            40,                         -- height
            {x = 15, y = -5},           -- knockback speed
            {x = 60, y = -20},          -- offset position from center
            6,                          -- setup time in frames
            6,                          -- hitbox duration in seconds
            6),                         -- accomodation in frames

            [1] = attack.AttackHitbox (
            70,                         -- width
            65,                         -- height
            {x = 23, y = -10},          -- knockback speed
            {x = 70, y = -20},          -- offset position from center
            6,                          -- setup time in frames
            6,                          -- hitbox duration in seconds
            6),                         -- accomodation in frames

            [2] = attack.AttackHitbox (
            80,                         -- width
            100,                        -- height
            {x = 33, y = -16},          -- knockback speed
            {x = 80, y = -20},          -- offset position from center
            6,                          -- setup time in frames
            6,                          -- hitbox duration in seconds
            6),                         -- accomodation in frames
        }, "RIGHT", "b", 4),

        up = attack.Attack({
            [0] = attack.AttackHitbox (
            25,                         -- width
            50,                         -- height
            {x = 0, y = -10},           -- knockback speed
            {x = 0, y = -100},          -- offset position from center
            6,                          -- setup time in frames
            6,                          -- hitbox duration in seconds
            6),                         -- accomodation in frames

            [1] = attack.AttackHitbox (
            40,                         -- width
            70,                         -- height
            {x = 0, y = -23},           -- knockback speed
            {x = 0, y = -110},          -- offset position from center
            6,                          -- setup time in frames
            6,                          -- hitbox duration in seconds
            6),                         -- accomodation in frames

            [2] = attack.AttackHitbox (
            50,                         -- width
            85,                         -- height
            {x = 0, y = -33},           -- knockback speed
            {x = 0, y = -120},          -- offset position from center
            6,                          -- setup time in frames
            6,                          -- hitbox duration in seconds
            6)                          -- accomodation in frames
        }, "UP", "y", 4),

        down = attack.Attack({
            [0] = attack.AttackHitbox (
            32,                         -- width
            20,                         -- height
            {x = 0, y = 10},            -- knockback speed
            {x = 0, y = 43},            -- offset position from center
            6,                          -- setup time in frames
            6,                          -- hitbox duration in seconds
            6),                         -- accomodation in frames

            [1] = attack.AttackHitbox (
            45,                         -- width
            20,                         -- height
            {x = 0, y = -20},            -- knockback speed
            {x = 0, y = 43},            -- offset position from center
            4,                          -- setup time in frames
            6,                          -- hitbox duration in seconds
            6),                         -- accomodation in frames

            [2] = attack.AttackHitbox (
            60,                         -- width
            30,                         -- height
            {x = 0, y = -33},            -- knockback speed
            {x = 0, y = 43},            -- offset position from center
            4,                          -- setup time in frames
            6,                          -- hitbox duration in seconds
            6),                         -- accomodation in frames

            meteor_1 = attack.AttackHitbox (
            32,                         -- width
            20,                         -- height
            {x = 0, y = 15},            -- knockback speed
            {x = 0, y = 43},            -- offset position from center
            4,                          -- setup time in frames
            6,                          -- hitbox duration in seconds
            6,                          -- accomodation in frames
            30),                        -- meteor attack speed

            meteor_2 = attack.AttackHitbox (
            45,                         -- width
            20,                         -- height
            {x = 0, y = 20},            -- knockback speed
            {x = 0, y = 43},            -- offset position from center
            4,                          -- setup time in frames
            6,                          -- hitbox duration in seconds
            6,                          -- accomodation in frames
            50)                         -- meteor attack speed

        }, "DOWN", "a", 4)
    }
end)

return attackData

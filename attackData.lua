local utils = require "utils"
local attackHitbox = require "attackHitbox"

local attackData = {}
setfenv (1, attackData)

AttackData = utils.defineStruct (function ()
    return {
        left_0 = attackHitbox.AttackHitbox (
        60,                         -- width
        40,                         -- height
        {x = -15, y = -5},      -- knockback speed
        {x = -60, y = -20},         -- offset position from center
        4,                          -- setup time in frames
        6,                          -- hitbox duration in seconds
        6),                          -- accomodation in frames


        left_1 = attackHitbox.AttackHitbox (
        70,                         -- width
        65,                         -- height
        {x = -23, y = -10},      -- knockback speed
        {x = -70, y = -20},         -- offset position from center
        4,                          -- setup time in frames
        6,                          -- hitbox duration in seconds
        6),                          -- accomodation in frames


        left_2 = attackHitbox.AttackHitbox (
        80,                         -- width
        100,                         -- height
        {x = -33, y = -16},      -- knockback speed
        {x = -80, y = -20},         -- offset position from center
        4,                          -- setup time in frames
        6,                          -- hitbox duration in seconds
        6),                          -- accomodation in frames

        right_0 = attackHitbox.AttackHitbox (
        60,                         -- width
        40,                         -- height
        {x = 15, y = -5},       -- knockback speed
        {x = 60, y = -20},          -- offset position from center
        4,                          -- setup time in frames
        6,                          -- hitbox duration in seconds
        6),                          -- accomodation in frames

        right_1 = attackHitbox.AttackHitbox (
        70,                         -- width
        65,                         -- height
        {x = 23, y = -10},       -- knockback speed
        {x = 70, y = -20},          -- offset position from center
        4,                          -- setup time in frames
        6,                          -- hitbox duration in seconds
        6),                          -- accomodation in frames

        right_2 = attackHitbox.AttackHitbox (
        80,                         -- width
        100,                         -- height
        {x = 33, y = -16},       -- knockback speed
        {x = 80, y = -20},          -- offset position from center
        4,                          -- setup time in frames
        6,                          -- hitbox duration in seconds
        6),                          -- accomodation in frames

        up_0 = attackHitbox.AttackHitbox (
        25,                        -- width
        50,                         -- height
        {x = 0, y = -10},         -- knockback speed
        {x = 0, y = -100},           -- offset position from center
        4,                          -- setup time in frames
        6,                          -- hitbox duration in seconds
        6),                          -- accomodation in frames

        up_1 = attackHitbox.AttackHitbox (
        40,                        -- width
        70,                         -- height
        {x = 0, y = -23},         -- knockback speed
        {x = 0, y = -110},           -- offset position from center
        4,                          -- setup time in frames
        6,                          -- hitbox duration in seconds
        6),                          -- accomodation in frames

        up_2 = attackHitbox.AttackHitbox (
        50,                        -- width
        85,                         -- height
        {x = 0, y = -33},         -- knockback speed
        {x = 0, y = -120},           -- offset position from center
        4,                          -- setup time in frames
        6,                          -- hitbox duration in seconds
        6),                          -- accomodation in frames

        down_0 = attackHitbox.AttackHitbox (
        32,                        -- width
        20,                         -- height
        {x = 0, y = 10},         -- knockback speed
        {x = 0, y = 55},            -- offset position from center
        4,                          -- setup time in frames
        6,                          -- hitbox duration in seconds
        6),                          -- accomodation in frames

        down_1 = attackHitbox.AttackHitbox (
        45,                        -- width
        20,                         -- height
        {x = 0, y = -20},         -- knockback speed
        {x = 0, y = 43},            -- offset position from center
        4,                          -- setup time in frames
        6,                          -- hitbox duration in seconds
        6),                          -- accomodation in frames

        down_2 = attackHitbox.AttackHitbox (
        60,                        -- width
        30,                         -- height
        {x = 0, y = -33},         -- knockback speed
        {x = 0, y = 43},            -- offset position from center
        4,                          -- setup time in frames
        6,                          -- hitbox duration in seconds
        6)                          -- accomodation in frames
    }
end)

return attackData

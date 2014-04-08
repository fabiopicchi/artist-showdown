local love = love

local framedata = {}
setfenv(1, framedata)

local frames = {
	love.graphics.newQuad= (0, 0, 256, 256, 4096, 4096)
	love.graphics.newQuad= (256, 0, 256, 256, 4096, 4096)
	love.graphics.newQuad= (0, 256, 256, 256, 4096, 4096)
	love.graphics.newQuad= (256, 256, 256, 256, 4096, 4096)
	love.graphics.newQuad= (512, 0, 256, 256, 4096, 4096)
	love.graphics.newQuad= (512, 256, 256, 256, 4096, 4096)
	love.graphics.newQuad= (768, 0, 256, 256, 4096, 4096)
	love.graphics.newQuad= (768, 256, 256, 256, 4096, 4096)
	love.graphics.newQuad= (0, 512, 256, 256, 4096, 4096)
	love.graphics.newQuad= (0, 768, 256, 256, 4096, 4096)
	love.graphics.newQuad= (256, 512, 256, 256, 4096, 4096)
	love.graphics.newQuad= (512, 512, 256, 256, 4096, 4096)
	love.graphics.newQuad= (256, 768, 256, 256, 4096, 4096)
	love.graphics.newQuad= (512, 768, 256, 256, 4096, 4096)
	love.graphics.newQuad= (768, 512, 256, 256, 4096, 4096)
	love.graphics.newQuad= (768, 768, 256, 256, 4096, 4096)
	love.graphics.newQuad= (1024, 0, 256, 256, 4096, 4096)
	love.graphics.newQuad= (1280, 0, 256, 256, 4096, 4096)
	love.graphics.newQuad= (1024, 256, 256, 256, 4096, 4096)
	love.graphics.newQuad= (1536, 0, 256, 256, 4096, 4096)
	love.graphics.newQuad= (1280, 256, 256, 256, 4096, 4096)
	love.graphics.newQuad= (1024, 512, 256, 256, 4096, 4096)
	love.graphics.newQuad= (1280, 512, 256, 256, 4096, 4096)
	love.graphics.newQuad= (1024, 768, 256, 256, 4096, 4096)
	love.graphics.newQuad= (1536, 256, 256, 256, 4096, 4096)
	love.graphics.newQuad= (1792, 0, 256, 256, 4096, 4096)
	love.graphics.newQuad= (1792, 256, 256, 256, 4096, 4096)
	love.graphics.newQuad= (1536, 512, 256, 256, 4096, 4096)
	love.graphics.newQuad= (1280, 768, 256, 256, 4096, 4096)
	love.graphics.newQuad= (1536, 768, 256, 256, 4096, 4096)
	love.graphics.newQuad= (1792, 512, 256, 256, 4096, 4096)
	love.graphics.newQuad= (1792, 768, 256, 256, 4096, 4096)
	love.graphics.newQuad= (0, 1024, 256, 256, 4096, 4096)
	love.graphics.newQuad= (256, 1024, 256, 256, 4096, 4096)
	love.graphics.newQuad= (0, 1280, 256, 256, 4096, 4096)
	love.graphics.newQuad= (256, 1280, 256, 256, 4096, 4096)
	love.graphics.newQuad= (0, 1536, 256, 256, 4096, 4096)
	love.graphics.newQuad= (512, 1024, 256, 256, 4096, 4096)
	love.graphics.newQuad= (256, 1536, 256, 256, 4096, 4096)
	love.graphics.newQuad= (0, 1792, 256, 256, 4096, 4096)
	love.graphics.newQuad= (512, 1280, 256, 256, 4096, 4096)
	love.graphics.newQuad= (768, 1024, 256, 256, 4096, 4096)
	love.graphics.newQuad= (1024, 1024, 256, 256, 4096, 4096)
	love.graphics.newQuad= (512, 1536, 256, 256, 4096, 4096)
	love.graphics.newQuad= (256, 1792, 256, 256, 4096, 4096)
	love.graphics.newQuad= (768, 1280, 256, 256, 4096, 4096)
	love.graphics.newQuad= (512, 1792, 256, 256, 4096, 4096)
	love.graphics.newQuad= (1024, 1280, 256, 256, 4096, 4096)
	love.graphics.newQuad= (768, 1536, 256, 256, 4096, 4096)
	love.graphics.newQuad= (1280, 1024, 256, 256, 4096, 4096)
	love.graphics.newQuad= (1024, 1536, 256, 256, 4096, 4096)
	love.graphics.newQuad= (768, 1792, 256, 256, 4096, 4096)
	love.graphics.newQuad= (1536, 1024, 256, 256, 4096, 4096)
	love.graphics.newQuad= (1280, 1280, 256, 256, 4096, 4096)
	love.graphics.newQuad= (1536, 1280, 256, 256, 4096, 4096)
	love.graphics.newQuad= (1280, 1536, 256, 256, 4096, 4096)
	love.graphics.newQuad= (1024, 1792, 256, 256, 4096, 4096)
	love.graphics.newQuad= (1792, 1024, 256, 256, 4096, 4096)
	love.graphics.newQuad= (1280, 1792, 256, 256, 4096, 4096)
	love.graphics.newQuad= (1792, 1280, 256, 256, 4096, 4096)
	love.graphics.newQuad= (1536, 1536, 256, 256, 4096, 4096)
	love.graphics.newQuad= (1792, 1536, 256, 256, 4096, 4096)
	love.graphics.newQuad= (1536, 1792, 256, 256, 4096, 4096)
	love.graphics.newQuad= (1792, 1792, 256, 256, 4096, 4096)
	love.graphics.newQuad= (2048, 0, 256, 256, 4096, 4096)
	love.graphics.newQuad= (2304, 0, 256, 256, 4096, 4096)
	love.graphics.newQuad= (2048, 256, 256, 256, 4096, 4096)
	love.graphics.newQuad= (2304, 256, 256, 256, 4096, 4096)
	love.graphics.newQuad= (2048, 512, 256, 256, 4096, 4096)
	love.graphics.newQuad= (2560, 0, 256, 256, 4096, 4096)
	love.graphics.newQuad= (2304, 512, 256, 256, 4096, 4096)
	love.graphics.newQuad= (2048, 768, 256, 256, 4096, 4096)
	love.graphics.newQuad= (2816, 0, 256, 256, 4096, 4096)
	love.graphics.newQuad= (2560, 256, 256, 256, 4096, 4096)
	love.graphics.newQuad= (2816, 256, 256, 256, 4096, 4096)
	love.graphics.newQuad= (2560, 512, 256, 256, 4096, 4096)
	love.graphics.newQuad= (2304, 768, 256, 256, 4096, 4096)
	love.graphics.newQuad= (2048, 1024, 256, 256, 4096, 4096)
	love.graphics.newQuad= (3072, 0, 256, 256, 4096, 4096)
	love.graphics.newQuad= (2816, 512, 256, 256, 4096, 4096)
	love.graphics.newQuad= (2560, 768, 256, 256, 4096, 4096)
	love.graphics.newQuad= (2304, 1024, 256, 256, 4096, 4096)
	love.graphics.newQuad= (2048, 1280, 256, 256, 4096, 4096)
	love.graphics.newQuad= (3328, 0, 256, 256, 4096, 4096)
	love.graphics.newQuad= (3072, 256, 256, 256, 4096, 4096)
	love.graphics.newQuad= (2304, 1280, 256, 256, 4096, 4096)
	love.graphics.newQuad= (2048, 1536, 256, 256, 4096, 4096)
	love.graphics.newQuad= (3584, 0, 256, 256, 4096, 4096)
	love.graphics.newQuad= (3328, 256, 256, 256, 4096, 4096)
	love.graphics.newQuad= (3072, 512, 256, 256, 4096, 4096)
	love.graphics.newQuad= (2816, 768, 256, 256, 4096, 4096)
	love.graphics.newQuad= (2560, 1024, 256, 256, 4096, 4096)
	love.graphics.newQuad= (3072, 768, 256, 256, 4096, 4096)
	love.graphics.newQuad= (2816, 1024, 256, 256, 4096, 4096)
	love.graphics.newQuad= (2560, 1280, 256, 256, 4096, 4096)
	love.graphics.newQuad= (3840, 0, 256, 256, 4096, 4096)
	love.graphics.newQuad= (3584, 256, 256, 256, 4096, 4096)
	love.graphics.newQuad= (3328, 512, 256, 256, 4096, 4096)
	love.graphics.newQuad= (2304, 1536, 256, 256, 4096, 4096)
	love.graphics.newQuad= (2048, 1792, 256, 256, 4096, 4096)
	love.graphics.newQuad= (2304, 1792, 256, 256, 4096, 4096)
	love.graphics.newQuad= (3840, 256, 256, 256, 4096, 4096)
	love.graphics.newQuad= (3584, 512, 256, 256, 4096, 4096)
	love.graphics.newQuad= (3328, 768, 256, 256, 4096, 4096)
	love.graphics.newQuad= (2560, 1536, 256, 256, 4096, 4096)
	love.graphics.newQuad= (2816, 1280, 256, 256, 4096, 4096)
	love.graphics.newQuad= (3072, 1024, 256, 256, 4096, 4096)
	love.graphics.newQuad= (3328, 1024, 256, 256, 4096, 4096)
	love.graphics.newQuad= (2816, 1536, 256, 256, 4096, 4096)
	love.graphics.newQuad= (2560, 1792, 256, 256, 4096, 4096)
	love.graphics.newQuad= (3072, 1280, 256, 256, 4096, 4096)
	love.graphics.newQuad= (3840, 512, 256, 256, 4096, 4096)
	love.graphics.newQuad= (3584, 768, 256, 256, 4096, 4096)
	love.graphics.newQuad= (3072, 1536, 256, 256, 4096, 4096)
	love.graphics.newQuad= (3840, 768, 256, 256, 4096, 4096)
	love.graphics.newQuad= (3584, 1024, 256, 256, 4096, 4096)
	love.graphics.newQuad= (2816, 1792, 256, 256, 4096, 4096)
	love.graphics.newQuad= (3328, 1280, 256, 256, 4096, 4096)
	love.graphics.newQuad= (3584, 1280, 256, 256, 4096, 4096)
	love.graphics.newQuad= (3328, 1536, 256, 256, 4096, 4096)
	love.graphics.newQuad= (3840, 1024, 256, 256, 4096, 4096)
	love.graphics.newQuad= (3072, 1792, 256, 256, 4096, 4096)
	love.graphics.newQuad= (3840, 1280, 256, 256, 4096, 4096)
	love.graphics.newQuad= (3328, 1792, 256, 256, 4096, 4096)
	love.graphics.newQuad= (3584, 1536, 256, 256, 4096, 4096)
	love.graphics.newQuad= (3840, 1536, 256, 256, 4096, 4096)
	love.graphics.newQuad= (3584, 1792, 256, 256, 4096, 4096)
	love.graphics.newQuad= (3840, 1792, 256, 256, 4096, 4096)
	love.graphics.newQuad= (0, 2048, 256, 256, 4096, 4096)
	love.graphics.newQuad= (256, 2048, 256, 256, 4096, 4096)
	love.graphics.newQuad= (0, 2304, 256, 256, 4096, 4096)
	love.graphics.newQuad= (512, 2048, 256, 256, 4096, 4096)
	love.graphics.newQuad= (256, 2304, 256, 256, 4096, 4096)
	love.graphics.newQuad= (0, 2560, 256, 256, 4096, 4096)
	love.graphics.newQuad= (512, 2304, 256, 256, 4096, 4096)
	love.graphics.newQuad= (256, 2560, 256, 256, 4096, 4096)
	love.graphics.newQuad= (0, 2816, 256, 256, 4096, 4096)
	love.graphics.newQuad= (768, 2048, 256, 256, 4096, 4096)
}

local animations = {
    IDLE = {1, 8, true},
    JUMP = {9, 10, true},
    FALL = {11, 12, true},
    DASH = {13, 14, true},
    MOVING = {15, 26, true},
    ATTACK_CHARGE_HOR_0 = {27, 28, true},
    ATTACK_HOR_0 = {29, 34, false},
    ATTACK_CHARGE_HOR_1 = {35, 36, true},
    ATTACK_HOR_1 = {37, 42, false},
    ATTACK_CHARGE_HOR_2 = {43, 44, true},
    ATTACK_HOR_2 = {45, 50, false},
    ATTACK_CHARGE_UP_0 = {51, 52, true},
    ATTACK_UP_0 = {53, 58, false},
    ATTACK_CHARGE_UP_1 = {59, 60, true},
    ATTACK_UP_1 = {61, 66, false},
    ATTACK_CHARGE_UP_2 = {67, 68, true},
    ATTACK_UP_2 = {69, 74, false},
    ATTACK_CHARGE_DOWN_0 = {75, 76, true},
    ATTACK_DOWN_0 = {77, 80, false},
    ATTACK_CHARGE_DOWN_1 = {81, 82, true},
	ATTACK_SETUP_DOWN_1 = {83, 84, false},
    ATTACK_DOWN_LOOP_1 = {85, 86, true},
    ATTACK_CHARGE_DOWN_2 = {87, 88, true},
	ATTACK_SETUP_DOWN_2= {89, 90, false},
    ATTACK_DOWN_LOOP_2 = {91, 92, true},
	ATTACK_DOWN_GROUND = {93, 98, false},
    EXPRESSION_SETUP = {99, 111, false},
    EXPRESSION = {112, 115, true},
    EXPRESSION_ACCOMODATION = {116, 119, false},
    TAUNT_SETUP = {120, 126, false},
	TAUNT = {127, 133, true},
    HIT = {135, 134, false},
    LAUNCHED = {136, 136, false},
    BLOCK = {137, 138, false},
}

Player_1 = {
    imgFile = "band_B.png",
    frames = frames,
    animations = animations
}

Player_2 = {
    imgFile = "band_R.png",
    frames = frames,
    animations = animations
}

Player_3 = {
    imgFile = "band_G.png",
    frames = frames,
    animations = animations
}

Player_4 = {
    imgFile = "band_Y.png",
    frames = frames,
    animations = animations
}

return framedata

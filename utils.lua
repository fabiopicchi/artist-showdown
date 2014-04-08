local print = print
local ipairs = ipairs
local pairs = pairs
local type = type
local setmetatable = setmetatable
local tostring = tostring

local utils = {}
setfenv (1, utils)

local function stringfyTable (t, depth)
    local function indent (val)
        for i = 0, val do
            str = str .. "    "
        end
    end

    str = "{\n"
    for k, v in pairs(t) do
        indent(depth)
        if type(v) == "table" then
            str = str .. k .. ": " .. stringfyTable(v, depth + 1)
        else
            str = str .. k .. ": " .. tostring(v) .. "\n"
        end
    end
    indent(depth - 1)
    str = str .. "}\n"
    return str
end

function printTable (t)
    print(stringfyTable (t, 0))
end


function copyTable (t)
    local copy = {}

    for k, v in pairs(t) do
        if type(v) == "table" then
            copy[k] = copyTable(v)
        else
            copy[k] = v
        end
    end

    return copy
end

function debug (str)
    print (str)
end

function defineStruct (arg)
    if type(arg) == "table" then
        local table = arg
        arg = function ()
            return copyTable(table)
        end
    end

    return setmetatable({}, {
        __call = function (cls, ...)
            return arg(...)
        end
    })
end 

local function createClassInstance (cls, constructor, ...)
    local instance = setmetatable({}, cls)

    if cls.__constructor then
        instance:__constructor(...) 
    end

    return instance
end

local function defineConstructor (cls, constructor)
    if constructor then
        cls.__constructor = constructor
    end
end

function defineClass (constructor)
    local newClass = setmetatable({}, {
        __call = function (cls, ...)
            return createClassInstance(cls, constructor, ...)
        end
    })
    newClass.__index = newClass
    defineConstructor (newClass, constructor)
    return newClass
end

function inheritsFrom (base, constructor)
    local newClass = setmetatable({}, {
        __call = function(cls, ...)
            return createClassInstance(cls, constructor, ...)
        end,
        __index = base
    })
    newClass.__index = newClass
    defineConstructor (newClass, constructor)
    return newClass
end

return utils

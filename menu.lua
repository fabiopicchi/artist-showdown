local utils = require "utils"

local menu = {}
setfenv(1, menu)

Menu = utils.defineClass(function (self, callbacks)
    self.callbacks = callbacks
    self.option = 1
end)

function Menu:nextOption()
    self.option = (self.option) % #self.callbacks + 1
end

function Menu:previousOption()
    self.option = (self.option - 2) % #self.callbacks + 1
end

function Menu:selectOption ()
    self.callbacks[self.option]()
end

function Menu:gotoOption (i)
    self.option = (i - 1) % #self.callbacks + 1
end

return menu

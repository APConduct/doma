local doma = require("doma")
local love = require("love")

local myContainer = doma.container(50, 50, 200, 150)

local btn1 = doma.button("Click Me", 20, 20, 100, 30, function()
    print("Button 1 clicked!")
end)

local btn2 = doma.button("Another", 20, 60, 100, 30, function()
    print("Button 2 clicked!")
end)

myContainer:addElement(btn1)
myContainer:addElement(btn2)

function love.draw()
    myContainer:draw()
end

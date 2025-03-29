local doma = require("doma")
local love = require("love")
local event = doma.event

local myContainer
local draggable

function love.load()
    myContainer = doma.container(50, 50, 300, 200)

    local btn1 = doma.button("Button 1", 20, 20, 100, 30, function()
        print("Button 1 clicked!")
    end)

    local btn2 = doma.button("Button 2", 20, 60, 100, 30, function()
        print("Button 2 clicked!")
    end)

    draggable = doma.draggable(140, 20, 50, 50)

    myContainer:add_element(btn1)
    myContainer:add_element(btn2)
    myContainer:add_element(draggable)
end

function love.update(dt)
    -- Update logic here if needed
end

function love.draw()
    doma.draw() -- This is all we need now
end

function love.mousepressed(x, y, button)
    event.trigger("mousepressed", x, y, button)
end

function love.mousemoved(x, y, dx, dy)
    event.trigger("mousemoved", x, y, dx, dy)
end

function love.mousereleased(x, y, button)
    event.trigger("mousereleased", x, y, button)
end

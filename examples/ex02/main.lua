local love = require("love")
local doma = require("doma")
local event = doma.event
local backend = doma.backend

local button -- Declare button outside love.load so it persists

function love.load()
    love.window.setTitle("doma UI Demo")
    -- Create the button once during load
    button = doma.button("Click Me", 50, 50, 100, 40,
        function()
            print("Button Clicked!")
        end,
        function()
            print("Hovered!")
        end,
        function()
            print("Button Released!")
        end
    )
end

function love.update(dt)
    local title = doma.element("text", { text = "Hello, doma!", x = 50, y = 20 })
    -- Don't recreate the button here
    -- Just update it if needed
end

function love.draw()
    doma.draw()
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

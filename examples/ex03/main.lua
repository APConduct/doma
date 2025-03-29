local love = require("love")
local doma = require("doma")
local event = doma.event

local CURSOR_BLINK_TIME = 0.5
local INPUT_PADDING = 5

local input -- Keep reference to input element

function love.load()
    -- Create a text input
    input = doma.textinput(50, 50, 200, 40, "Enter text...", {
        on_change = function(text)
            print("Text changed:", text)
        end,
        on_submit = function(text)
            print("Submitted:", text)
        end
    })
end

function love.update(dt)
    -- Update cursor blink if needed
    if input.props.selected then
        input.props.cursor_timer = (input.props.cursor_timer or 0) + dt
        if input.props.cursor_timer >= CURSOR_BLINK_TIME then
            input.props.cursor_visible = not input.props.cursor_visible
            input.props.cursor_timer = input.props.cursor_timer - CURSOR_BLINK_TIME
        end
    end
end

function love.draw()
    doma.draw()
end

-- Add required LÖVE callbacks
function love.textinput(t)
    event.trigger("textinput", t)
end

function love.keypressed(key)
    event.trigger("keypressed", key)
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

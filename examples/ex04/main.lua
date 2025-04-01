local love = require("love")
local doma = require("doma")
local event = doma.event

local radio_group

function love.load()
    radio_group = doma.radio_group("size", {
        { label = "Small",  value = "s" },
        { label = "Medium", value = "m" },
        { label = "Large",  value = "l" }
    }, {
        x = 50,
        y = 50,

        -- Basic colors
        text_color = { 1, 1, 1, 1 },           -- Default text color (white)
        hover_text_color = { 0.4, 0.8, 1, 1 }, -- Text color when hovering (light blue)

        dot_color = { 0.2, 0.6, 1, 1 },        -- Default selection dot color
        hover_dot_color = { 0.4, 0.8, 1, 1 },  -- Selection dot color when hovering

        hover_color = { 0.2, 0.3, 0.4, 1 },    -- Background color when hovering

        -- Event callbacks
        on_change = function(value, index)
            print("Selected size:", value, "at index", index)
        end,
        on_hover = function(value, index)
            print("Hovering over option:", value)
        end,
        on_end_hover = function(value, index)
            print("No longer hovering over option:", value)
        end
    })
end

function love.draw()
    -- love.graphics.setBackgroundColor(0.2, 0.2, 0.2) -- Set a gray background
    doma.draw()
end

function love.mousemoved(x, y, dx, dy)
    event.trigger("mousemoved", x, y, dx, dy)
end

function love.mousepressed(x, y, button, istouch, presses)
    event.trigger("mousepressed", x, y, button, istouch, presses)
end

function love.mousereleased(x, y, button, istouch, presses)
    event.trigger("mousereleased", x, y, button, istouch, presses)
end

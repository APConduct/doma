local love = require("love")
local backend = {}

if love then
    backend.graphics = {
        print = love.graphics.print,
        rectangle = love.graphics.rectangle,
        set_color = love.graphics.setColor, -- Changed set_color to setColor to match LÖVE's API
    }
    backend.mouse = {
        isDown = love.mouse.isDown, -- Changed is_down to isDown to match LÖVE's API
    }
end

return backend

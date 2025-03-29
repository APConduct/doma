local doma = require("doma")
local layout = require("doma.layout")
local love = require("love")

function love.load()
    love.window.setTitle("Doma Demo")
end

function love.update(dt)
    local title = doma.element("text", { text = "Hello, World!", x = 50, y = 20 })
    local button = doma.element("rect", { x = 50, y = 50, w = 100, h = 40, color = { 0.2, 0.6, 1, 1 } })
end

function love.draw()
    doma.draw()
end

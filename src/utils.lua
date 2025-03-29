local backend = require("src.backend")

local utils = {}

function utils.draw_rounded_rect(mode, x, y, w, h, radius)
    if radius <= 0 then
        backend.graphics.rectangle(mode, x, y, w, h)
        return
    end

    radius = math.min(radius, h / 2, w / 2) -- Ensure radius isn't too large

    -- Draw the rectangles for the center and edges
    backend.graphics.rectangle(mode, x + radius, y, w - 2 * radius, h)
    backend.graphics.rectangle(mode, x, y + radius, w, h - 2 * radius)

    -- Draw the corners
    backend.graphics.arc(mode, x + radius, y + radius, radius, math.pi, 3 * math.pi / 2)   -- Top-left
    backend.graphics.arc(mode, x + w - radius, y + radius, radius, 3 * math.pi / 2, 2 * math.pi) -- Top-right
    backend.graphics.arc(mode, x + radius, y + h - radius, radius, math.pi / 2, math.pi)   -- Bottom-left
    backend.graphics.arc(mode, x + w - radius, y + h - radius, radius, 0, math.pi / 2)     -- Bottom-right
end

return utils

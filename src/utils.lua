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
    backend.graphics.arc(mode, x + radius, y + radius, radius, math.pi, 3 * math.pi / 2)         -- Top-left
    backend.graphics.arc(mode, x + w - radius, y + radius, radius, 3 * math.pi / 2, 2 * math.pi) -- Top-right
    backend.graphics.arc(mode, x + radius, y + h - radius, radius, math.pi / 2, math.pi)         -- Bottom-left
    backend.graphics.arc(mode, x + w - radius, y + h - radius, radius, 0, math.pi / 2)           -- Bottom-right
end

function utils.calculate_text_position(text, x, y, w, h, align)
    local font = backend.graphics.get_font()
    local text_w = font:getWidth(text)
    local text_h = font:getHeight()

    local text_x = x
    local text_y = y + (h - text_h) / 2 -- Vertical center by default

    if align == "center" then
        text_x = x + (w - text_w) / 2
    elseif align == "right" then
        text_x = x + w - text_w - 5 -- 5px padding from right
    else                            -- "left" or default
        text_x = x + 5              -- 5px padding from left
    end

    return text_x, text_y
end

-- Add text wrapping support
function utils.wrap_text(text, max_width, font)
    local lines = {}
    local words = {}

    -- Split text into words
    for word in text:gmatch("%S+") do
        table.insert(words, word)
    end

    local current_line = ""
    for i, word in ipairs(words) do
        local test_line = current_line .. (current_line == "" and "" or " ") .. word
        if font:getWidth(test_line) <= max_width then
            current_line = test_line
        else
            if current_line ~= "" then
                table.insert(lines, current_line)
            end
            current_line = word
        end
    end

    if current_line ~= "" then
        table.insert(lines, current_line)
    end

    return lines
end

return utils

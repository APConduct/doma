local backend = require("src.backend")

local utils = {}

utils.clone = function(t)
    if type(t) ~= "table" then return t end
    local copy = {}
    for k, v in pairs(t) do
        copy[k] = type(v) == "table" and utils.clone(v) or v
    end
    return copy
end

utils.merge = function(t1, t2)
    local merged = utils.clone(t1)
    for k, v in pairs(t2) do
        if type(v) == "table" and type(merged[k]) == "table" then
            merged[k] = utils.merge(merged[k], v)
        else
            merged[k] = v
        end
    end
    return merged
end

utils.colors = {
    rgba = function(r, g, b, a)
        return { r / 255, g / 255, b / 255, a / 255 }
    end,

    hex_to_rgb = function(hex)
        hex = hex:gsub("#", "")
        return {
            tonumber("0x" .. hex:sub(1, 2)) / 255,
            tonumber("0x" .. hex:sub(3, 4)) / 255,
            tonumber("0x" .. hex:sub(5, 6)) / 255,
            #hex == 8 and tonumber("0x" .. hex:sub(7, 8)) / 255 or 1
        }
    end,

    rgb_to_hex = function(r, g, b, a)
        local hex = string.format("%02x%02x%02x", r * 255, g * 255, b * 255)
        if a then
            hex = hex .. string.format("%02x", a * 255)
        end
        return hex
    end,

}

utils.math = {
    lerp = function(a, b, t)
        return a + (b - a) * t
    end,

    clamp = function(val, min, max)
        return math.min(math.max(val, min), max)
    end
}

utils.string = {
    split = function(str, delimiter)
        local result = {}
        for match in (str .. delimiter):gmatch("(.-)" .. delimiter) do
            table.insert(result, match)
        end
        return result
    end
}

function utils.draw_rounded_rect(mode, x, y, w, h, radius)
    -- Safety checks for nil values
    if not x or not y or not w or not h then
        print("Warning: Missing dimensions in draw_rounded_rect", x, y, w, h)
        return
    end

    -- Ensure radius is a number and not too large
    radius = radius or 0
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

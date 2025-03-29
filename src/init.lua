local layout = require("src.layout")
local backend = require("src.backend")
local event = require("src.event")

local doma = {
    elements = {}
}

function doma.element(type, props)
    local elem = {
        type = type,
        props = props or {}
    }
    table.insert(doma.elements, elem)
    return elem
end

function doma.draw()
    for _, elem in ipairs(doma.elements) do
        if elem.type == "text" then
            backend.graphics.set_color(elem.props.color or { 1, 1, 1, 1 })
            backend.graphics.rectangle("fill", elem.props.x or 0, elem.props.y or 0, elem.props.w or 100,
                elem.props.h or 50)
        end
    end
    doma.elements = {} -- Clear the elements table after drawing each frame
end

doma.layout = layout
doma.backend = backend
doma.event = event

return doma

local layout = require("src.layout")
local backend = require("src.backend")
local event = require("src.event")
local utils = require("src.utils")

local White = { 1, 1, 1, 1 }
local Black = { 0, 0, 0, 1 }

local doma = {
    elements = {},
    persistent_elements = {},
    layout = layout,
    backend = backend,
    event = event,
}

doma.style = {
    font = backend.graphics.new_font(14),
    text_color = White,
}


function doma.element(type, props)
    local elem = {
        type = type,
        props = props or {},
    }
    table.insert(doma.elements, elem)
    return elem
end

function doma.button(label, x, y, w, h, on_click, on_hover, on_end_hover)
    local btn = doma.element("rect", {
        x = x,
        y = y,
        w = w,
        h = h,
        -- default_color = { 0.2, 0.6, 1, 1 },
        default_color = White,
        hover_color = Black,
        -- current_color = { 0.2, 0.6, 1, 1 },
        current_color = White,
        label = label,
        default_text_color = Black,
        current_text_color = Black,
        hover_text_color = White,
        radius = 5 -- Default corner radius
    })

    -- Mouse hover event
    event.on("mousemoved", function(mx, my)
        local abs_x = btn.props.x + (btn.props.parent and btn.props.parent.props.x or 0)
        local abs_y = btn.props.y + (btn.props.parent and btn.props.parent.props.y or 0)

        if mx >= abs_x and mx <= abs_x + w and my >= abs_y and my <= abs_y + h then
            btn.props.current_color = btn.props.hover_color
            btn.props.current_text_color = btn.props.hover_text_color
            if on_hover then on_hover() end
        else
            btn.props.current_color = btn.props.default_color
            btn.props.current_text_color = btn.props.default_text_color
            if on_end_hover then on_end_hover() end
        end
    end)

    -- Mouse click event
    event.on("mousepressed", function(mx, my, button)
        local abs_x = btn.props.x + (btn.props.parent and btn.props.parent.props.x or 0)
        local abs_y = btn.props.y + (btn.props.parent and btn.props.parent.props.y or 0)

        if button == 1 and mx >= abs_x and mx <= abs_x + w and my >= abs_y and my <= abs_y + h then
            if on_click then on_click() end
        end
    end)

    -- Only add to persistent_elements if it's not going to be in a container
    if not btn.props.parent then
        table.insert(doma.persistent_elements, btn)
    end

    return btn
end

function doma.draggable(x, y, w, h)
    local obj = doma.element("rect", {
        x = x,
        y = y,
        w = w,
        h = h,
        dragging = false,
        default_color = { 0.4, 0.4, 0.4, 1 },
        current_color = { 0.4, 0.4, 0.4, 1 }
    })

    -- Add to persistent elements
    table.insert(doma.persistent_elements, obj)

    event.on("mousepressed", function(mx, my, button)
        local absolute_x = obj.props.x + (obj.props.parent and obj.props.parent.props.x or 0)
        local absolute_y = obj.props.y + (obj.props.parent and obj.props.parent.props.y or 0)

        if button == 1 and
            mx >= absolute_x and
            mx <= absolute_x + w and
            my >= absolute_y and
            my <= absolute_y + h then
            obj.props.dragging = true
            obj.props.drag_offset_x = mx - absolute_x
            obj.props.drag_offset_y = my - absolute_y
        end
    end)

    event.on("mousemoved", function(mx, my)
        if obj.props.dragging then
            if obj.props.parent then
                -- If in container, constrain to container bounds
                local new_x = mx - obj.props.drag_offset_x - obj.props.parent.props.x
                local new_y = my - obj.props.drag_offset_y - obj.props.parent.props.y

                new_x = math.max(0, math.min(new_x, obj.props.parent.props.w - obj.props.w))
                new_y = math.max(0, math.min(new_y, obj.props.parent.props.h - obj.props.h))

                obj.props.x = new_x
                obj.props.y = new_y
            else
                -- If not in container, move freely
                obj.props.x = mx - obj.props.drag_offset_x
                obj.props.y = my - obj.props.drag_offset_y
            end
        end
    end)

    event.on("mousereleased", function()
        obj.props.dragging = false
    end)

    return obj
end

function doma.container(x, y, w, h)
    local cont = {
        type = "container",
        props = { x = x, y = y, w = w, h = h },
        children = {},
        persistent = true,
        draw = function(self)
            -- Draw container with slight rounding
            backend.graphics.set_color(0.2, 0.2, 0.2, 1)
            utils.draw_rounded_rect("fill", self.props.x, self.props.y, self.props.w, self.props.h, 3)

            for _, child in ipairs(self.children) do
                if child.props then
                    -- Use consistent color property names
                    backend.graphics.set_color(child.props.current_color or child.props.default_color)
                    utils.draw_rounded_rect("fill",
                        self.props.x + child.props.x,
                        self.props.y + child.props.y,
                        child.props.w,
                        child.props.h,
                        child.props.radius or 0
                    )
                    if child.props.label then
                        backend.graphics.set_color(child.props.current_text_color or child.props.default_text_color)
                        backend.graphics.print(child.props.label,
                            self.props.x + child.props.x + 5,
                            self.props.y + child.props.y + 5
                        )
                    end
                end
            end
        end
    }

    function cont:add_element(elem)
        elem.props.parent = self
        table.insert(self.children, elem)
    end

    -- Add container to persistent elements
    table.insert(doma.persistent_elements, cont)
    return cont
end

function doma.draw()
    backend.graphics.set_font(doma.style.font)

    -- Draw persistent elements that aren't children of containers
    for _, elem in ipairs(doma.persistent_elements) do
        if elem.type == "container" then
            elem:draw()
        elseif elem.type == "rect" and not elem.props.parent then
            backend.graphics.set_color(elem.props.current_color or elem.props.default_color or { 1, 1, 1, 1 })
            backend.graphics.rectangle("fill", elem.props.x, elem.props.y, elem.props.w, elem.props.h)

            if elem.props.label then
                backend.graphics.set_color(elem.props.current_text_color or elem.props.default_text_color or
                    Black)
                backend.graphics.print(elem.props.label, elem.props.x + 10, elem.props.y + 10)
            end
        end
    end

    -- Draw temporary elements
    for _, elem in ipairs(doma.elements) do
        if not elem.props.parent then
            -- Draw temporary elements that aren't in containers
            -- (Add drawing code here if needed)
        end
    end

    doma.elements = {}
end

return doma

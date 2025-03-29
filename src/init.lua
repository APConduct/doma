local layout = require("src.layout")
local backend = require("src.backend")
local event = require("src.event")


local doma = {
    elements = {},
    persistent_elements = {},
    layout = layout,
    backend = backend,
    event = event,
}

doma.style = {
    font = backend.graphics.new_font(14),
    text_color = { 1, 1, 1, 1 }, -- White
}


function doma.element(type, props)
    local elem = {
        type = type,
        props = props or {},
    }
    table.insert(doma.elements, elem)
    return elem
end

function doma.button(label, x, y, w, h, onClick, on_hover, on_end_hover)
    -- Check if the button already exists in persistent_elements
    for _, elem in ipairs(doma.persistent_elements) do
        if elem.props.x == x and elem.props.y == y and elem.props.label == label then
            return elem
        end
    end

    local btn = doma.element("rect", {
        x = x,
        y = y,
        w = w,
        h = h,
        defaultColor = { 0.2, 0.6, 1, 1 },
        hoverColor = { 0, 0, 0, 1 },
        currentColor = { 0.2, 0.6, 1, 1 },
        label = label
    })

    -- Add the button to persistent elements
    table.insert(doma.persistent_elements, btn)

    -- Mouse hover event
    event.on("mousemoved", function(mx, my)
        if mx >= x and mx <= x + w and my >= y and my <= y + h then
            btn.props.currentColor = btn.props.hoverColor
            if on_hover then on_hover() end
        else
            btn.props.currentColor = btn.props.defaultColor
            if on_end_hover then on_end_hover() end
        end
    end)

    -- Mouse click event
    event.on("mousepressed", function(mx, my, button)
        if button == 1 and mx >= x and mx <= x + w and my >= y and my <= y + h then
            if onClick then onClick() end
        end
    end)

    return btn
end

function doma.draggable(x, y, w, h)
    local obj = doma.element("rect", { x = x, y = y, w = w, h = h, dragging = false })

    event.on("mousepressed", function(mx, my, button)
        if button == 1 and mx >= obj.props.x and mx <= obj.props.x + w and my >= obj.props.y and my <= obj.props.y + h then
            obj.props.dragging = true
        end
    end)

    event.on("mousemoved", function(mx, my)
        if obj.props.dragging then
            obj.props.x = mx - w / 2
            obj.props.y = my - h / 2
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
        children = {}
    }

    -- Function to add elements to the container
    function cont:addElement(elem)
        table.insert(self.children, elem)
    end

    -- Function to draw container and its children
    function cont:draw()
        backend.graphics.set_color(0.2, 0.2, 0.2, 1) -- Background color
        backend.graphics.rectangle("fill", self.props.x, self.props.y, self.props.w, self.props.h)

        for _, child in ipairs(self.children) do
            -- Adjust child positions relative to container
            if child.props then
                backend.graphics.set_color(child.props.currentColor)
                backend.graphics.rectangle("fill", self.props.x + child.props.x, self.props.y + child.props.y,
                    child.props
                    .w, child.props.h)
                if child.props.label then
                    backend.graphics.set_color(1, 1, 1, 1)
                    backend.graphics.print(child.props.label, self.props.x + child.props.x + 5,
                        self.props.y + child.props.y + 5)
                end
            end
        end
    end

    return cont
end

function doma.draw()
    backend.graphics.set_font(doma.style.font)

    -- Draw persistent elements
    for _, elem in ipairs(doma.persistent_elements) do
        if elem.type == "rect" then
            backend.graphics.set_color(elem.props.currentColor or elem.props.defaultColor or { 1, 1, 1, 1 })
            backend.graphics.rectangle("fill", elem.props.x, elem.props.y, elem.props.w, elem.props.h)

            if elem.props.label then
                backend.graphics.set_color(doma.style.text_color)
                backend.graphics.print(elem.props.label, elem.props.x + 10, elem.props.y + 10)
            end
        end
    end

    -- Draw temporary elements
    for _, elem in ipairs(doma.elements) do
        -- ... same drawing code as before ...
    end

    doma.elements = {} -- Only clear temporary elements
end

return doma

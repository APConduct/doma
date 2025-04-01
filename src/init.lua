local layout = require("src.layout")
local backend = require("src.backend")
local event = require("src.event")
local utils = require("src.utils")

local CURSOR_BLINK_TIME = 0.5
local INPUT_PADDING = 5

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
        default_color = White,
        hover_color = Black,
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

function doma.textinput(x, y, w, h, placeholder, options)
    options = options or {}
    local input = doma.element("textinput", {
        x = x,
        y = y,
        w = w,
        h = h,
        text = "",
        placeholder = placeholder or "",
        cursor_position = 0,
        cursor_visible = true,
        cursor_timer = 0,
        selected = false,
        default_color = options.default_color or White,
        current_color = options.default_color or White,
        border_color = options.border_color or { 0.7, 0.7, 0.7, 1 },
        text_color = options.text_color or Black,
        placeholder_color = options.placeholder_color or { 0.7, 0.7, 0.7, 1 },
        radius = options.radius or 5,
        on_change = options.on_change,
        on_submit = options.on_submit,
        max_length = options.max_length or 100
    })

    -- Handle text input
    event.on("textinput", function(t)
        if input.props.selected and #input.props.text < input.props.max_length then
            input.props.text = input.props.text:sub(1, input.props.cursor_position)
                .. t
                .. input.props.text:sub(input.props.cursor_position + 1)
            input.props.cursor_position = input.props.cursor_position + 1
            if input.props.on_change then
                input.props.on_change(input.props.text)
            end
        end
    end)

    -- Handle keyboard events
    event.on("keypressed", function(key)
        if not input.props.selected then return end

        if key == "backspace" then
            if input.props.cursor_position > 0 then
                input.props.text = input.props.text:sub(1, input.props.cursor_position - 1)
                    .. input.props.text:sub(input.props.cursor_position + 1)
                input.props.cursor_position = input.props.cursor_position - 1
                if input.props.on_change then
                    input.props.on_change(input.props.text)
                end
            end
        elseif key == "return" then
            if input.props.on_submit then
                input.props.on_submit(input.props.text)
            end
            input.props.text = ""
            input.props.cursor_position = 0
            input.props.selected = false
        elseif key == "left" then
            input.props.cursor_position = math.max(0, input.props.cursor_position - 1)
        elseif key == "right" then
            input.props.cursor_position = math.min(#input.props.text, input.props.cursor_position + 1)
        end
    end)

    -- Handle mouse interaction
    event.on("mousepressed", function(mx, my, button)
        local abs_x = input.props.x + (input.props.parent and input.props.parent.props.x or 0)
        local abs_y = input.props.y + (input.props.parent and input.props.parent.props.y or 0)

        input.props.selected = mx >= abs_x and mx <= abs_x + w
            and my >= abs_y and my <= abs_y + h
    end)

    -- Add custom draw method
    input.draw = function(self)
        -- Draw background
        backend.graphics.set_color(self.props.current_color)
        utils.draw_rounded_rect("fill", self.props.x, self.props.y, self.props.w, self.props.h, self.props.radius)

        -- Draw border
        backend.graphics.set_color(self.props.border_color)
        utils.draw_rounded_rect("line", self.props.x, self.props.y, self.props.w, self.props.h, self.props.radius)

        -- Draw text or placeholder
        local text = self.props.text
        if text == "" and not self.props.selected then
            backend.graphics.set_color(self.props.placeholder_color)
            text = self.props.placeholder
        else
            backend.graphics.set_color(self.props.text_color)
        end

        local text_x, text_y = utils.calculate_text_position(text,
            self.props.x, self.props.y, self.props.w, self.props.h, "left")
        backend.graphics.print(text, text_x, text_y)

        -- Draw cursor
        if self.props.selected and self.props.cursor_visible then
            local cursor_x = text_x + doma.style.font:getWidth(text:sub(1, self.props.cursor_position))
            backend.graphics.set_color(self.props.text_color)
            backend.graphics.line(cursor_x, text_y, cursor_x, text_y + self.props.h - INPUT_PADDING * 2)
        end
    end

    table.insert(doma.persistent_elements, input)
    return input
end

function doma.radio_group(name, options, props)
    props = props or {}
    local group = doma.element("radio_group", {
        x = props.x or 0,
        y = props.y or 0,
        name = name,
        options = options,
        selected_value = props.default_value or options[1].value,
        spacing = props.spacing or 25,

        -- Default colors
        default_text_color = props.text_color or White,
        hover_text_color = props.hover_text_color or White,
        current_text_color = props.text_color or White,

        default_dot_color = props.dot_color or White,
        hover_dot_color = props.hover_dot_color or { 0.4, 0.7, 1, 1 },
        current_dot_color = props.dot_color or White,

        default_circle_color = props.circle_color or White,
        hover_circle_color = props.hover_circle_color or { 0.7, 0.8, 1, 1 },
        current_circle_color = props.circle_color or White,

        hover_background_color = props.hover_color or { 0.3, 0.3, 0.3, 1 },

        -- Sizes
        radio_size = props.radio_size or 16,
        dot_size = props.dot_size or 8,

        -- Callbacks for hover events
        on_change = props.on_change,
        on_hover = props.on_hover,
        on_end_hover = props.on_end_hover,

        -- State
        hovered_index = nil,
        hovered_option = nil
    })

    -- Calculate total height for positioning
    group.props.height = #options * group.props.spacing

    -- Mouse movement handler
    event.on("mousemoved", function(e, mx, my)
        local abs_x = tonumber(group.props.x) or 0
        if group.props.parent then
            abs_x = abs_x + (tonumber(group.props.parent.props.x) or 0)
        end

        local abs_y = tonumber(group.props.y) or 0
        if group.props.parent then
            abs_y = abs_y + (tonumber(group.props.parent.props.y) or 0)
        end

        -- Check which option is being hovered
        local old_hover = group.props.hovered_index
        group.props.hovered_index = nil
        group.props.hovered_option = nil

        for i, option in ipairs(options) do
            local spacing = tonumber(group.props.spacing) or 25
            local radio_size = tonumber(group.props.radio_size) or 16

            local option_y = abs_y + (i - 1) * spacing
            local hitbox_width = radio_size + 150 -- Width including label

            if mx >= abs_x and
                mx <= abs_x + hitbox_width and
                my >= option_y and
                my <= option_y + radio_size then
                group.props.hovered_index = i
                group.props.hovered_option = option

                -- Update colors for hover state
                group.props.current_text_color = group.props.hover_text_color
                group.props.current_dot_color = group.props.hover_dot_color
                group.props.current_circle_color = group.props.hover_circle_color

                -- Call hover callback if provided
                if group.props.on_hover then
                    group.props.on_hover(option.value, i)
                end

                break
            end
        end

        -- If hover state changed and we're no longer hovering
        if old_hover and not group.props.hovered_index then
            -- Reset colors to default
            group.props.current_text_color = group.props.default_text_color
            group.props.current_dot_color = group.props.default_dot_color
            group.props.current_circle_color = group.props.default_circle_color

            -- Call end_hover callback if provided
            if group.props.on_end_hover then
                group.props.on_end_hover(options[old_hover].value, old_hover)
            end
        end
    end)

    -- Click handler
    event.on("mousepressed", function(e, mx, my, button)
        if button == 1 and group.props.hovered_index then
            local old_value = group.props.selected_value
            group.props.selected_value = options[group.props.hovered_index].value

            if group.props.on_change and old_value ~= group.props.selected_value then
                group.props.on_change(group.props.selected_value, group.props.hovered_index)
            end
        end
    end)

    -- Custom draw method
    group.draw = function(self)
        local x = self.props.x
        local y = self.props.y

        for i, option in ipairs(self.props.options) do
            local option_y = y + (i - 1) * self.props.spacing
            local is_hovered = i == self.props.hovered_index
            local is_selected = option.value == self.props.selected_value

            -- Draw hover background
            if is_hovered then
                backend.graphics.set_color(unpack(self.props.hover_background_color))
                backend.graphics.rectangle("fill",
                    x - 4,
                    option_y - 4,
                    self.props.radio_size + 158,
                    self.props.radio_size + 8
                )
            end

            -- Draw radio circle - use hover color if hovered
            if is_hovered then
                backend.graphics.set_color(unpack(self.props.current_circle_color))
            else
                backend.graphics.set_color(unpack(self.props.default_circle_color))
            end

            backend.graphics.circle("line",
                x + self.props.radio_size / 2,
                option_y + self.props.radio_size / 2,
                self.props.radio_size / 2
            )

            -- Draw selection dot - use hover dot color if hovered
            if is_selected then
                if is_hovered then
                    backend.graphics.set_color(unpack(self.props.current_dot_color))
                else
                    backend.graphics.set_color(unpack(self.props.default_dot_color))
                end

                backend.graphics.circle("fill",
                    x + self.props.radio_size / 2,
                    option_y + self.props.radio_size / 2,
                    self.props.dot_size / 2
                )
            end

            -- Draw label - use hover text color if hovered
            if is_hovered then
                backend.graphics.set_color(unpack(self.props.current_text_color))
            else
                backend.graphics.set_color(unpack(self.props.default_text_color))
            end

            backend.graphics.print(
                option.label,
                x + self.props.radio_size + 8,
                option_y + (self.props.radio_size - doma.style.font:getHeight()) / 2
            )
        end
    end

    -- Add to persistent elements
    table.insert(doma.persistent_elements, group)
    return group
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
        elseif elem.type == "textinput" then
            elem:draw()
        elseif elem.type == "radio_group" then
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

local love = require("love")
local doma = require("doma")
local event = doma.event

local theme_buttons = {}
local animated_button
local animated_slider
local animate_checkbox

function love.load()
    love.window.setTitle("DOMA UI - Theming & Animations")

    -- Create main container
    local container = doma.container(50, 50, 600, 400)

    -- Add title
    local title = doma.element("text", {
        text = "Theme & Animation Demo",
        x = 20,
        y = 20,
        font_size = 24
    })
    container:add_element(title)

    -- Create theme selector buttons
    local theme_names = { "default", "dark", "light" }
    for i, theme_name in ipairs(theme_names) do
        local btn = doma.button(theme_name, 20 + (i - 1) * 120, 70, 100, 40, function()
            doma.theme.set(theme_name)
            update_theme_colors()
        end)
        table.insert(theme_buttons, btn)
        container:add_element(btn)
    end

    -- Create animated elements
    animated_button = doma.button("Animate Me", 20, 140, 140, 50, function()
        -- Start button animation when clicked
        doma.animation.tween(animated_button, "w", 140, 240, 0.5, {
            easing = "out_elastic",
            on_complete = function()
                doma.animation.tween(animated_button, "w", 240, 140, 0.5, {
                    easing = "in_out_cubic"
                })
            end
        })
    end)
    container:add_element(animated_button)

    animated_slider = doma.slider(20, 220, 300, 0, 100, 50, {
        show_value = true
    })
    container:add_element(animated_slider)

    -- Start an automatic animation for the slider
    doma.animation.tween(animated_slider, "value", 0, 100, 3, {
        easing = "in_out_cubic",
        repeat_count = -1, -- infinite
        repeat_delay = 0.5,
        on_update = function(target, progress)
            if target.props.on_change then
                target.props.on_change(target.props.value)
            end
        end
    })

    -- Add a checkbox to enable/disable animations
    animate_checkbox = doma.checkbox(20, 270, "Enable animations", true, {
        on_change = function(checked)
            if checked then
                -- Resume animations
                doma.animation.tween(animated_slider, "value", animated_slider.props.value, 100, 3, {
                    easing = "in_out_cubic",
                    repeat_count = -1,
                    repeat_delay = 0.5,
                    on_update = function(target, progress)
                        if target.props.on_change then
                            target.props.on_change(target.props.value)
                        end
                    end
                })
            else
                -- Cancel all animations
                for id, _ in pairs(doma.animation.active) do
                    doma.animation.cancel(id)
                end
            end
        end
    })
    container:add_element(animate_checkbox)

    -- Create a pulsing element to demonstrate more complex animation
    local pulse_circle = doma.element("circle", {
        x = 400,
        y = 220,
        radius = 40,
        color = { 0.4, 0.7, 1, 1 }
    })
    container:add_element(pulse_circle)

    -- Custom draw method for the circle
    pulse_circle.draw = function(self)
        -- Get backend from doma
        local backend = doma.backend

        if self.props.color then
            backend.graphics.set_color(unpack(self.props.color))
            backend.graphics.circle("fill",
                self.props.x + (self.props.parent and self.props.parent.props.x or 0),
                self.props.y + (self.props.parent and self.props.parent.props.y or 0),
                self.props.radius)
        end
    end
    -- Animate the circle to pulse
    doma.animation.keyframes(pulse_circle, "radius", {
        { time = 0,   value = 40 },
        { time = 0.5, value = 60 },
        { time = 1,   value = 40 }
    }, {
        duration = 2,
        repeat_count = -1,
        easing = "in_out_quad"
    })

    -- Animate circle color to change over time
    doma.animation.keyframes(pulse_circle, "color", {
        { time = 0,    value = { 0.4, 0.7, 1, 1 } },
        { time = 0.33, value = { 1, 0.4, 0.7, 1 } },
        { time = 0.66, value = { 0.7, 1, 0.4, 1 } },
        { time = 1,    value = { 0.4, 0.7, 1, 1 } }
    }, {
        duration = 6,
        repeat_count = -1,
        easing = "linear"
    })

    -- Update colors based on current theme
    update_theme_colors()
end

function update_theme_colors()
    local current_theme = doma.theme.get()

    -- Update colors for various UI components
    for _, button in ipairs(theme_buttons) do
        if button.props.label == doma.theme.current then
            -- Highlight current theme button
            button.props.default_color = current_theme.colors.accent
            button.props.current_color = current_theme.colors.accent
            button.props.default_text_color = current_theme.colors.background
            button.props.current_text_color = current_theme.colors.background
        else
            -- Regular appearance for other theme buttons
            button.props.default_color = current_theme.colors.primary
            button.props.current_color = current_theme.colors.primary
            button.props.default_text_color = current_theme.colors.text
            button.props.current_text_color = current_theme.colors.text
        end
    end

    -- Update animated button colors
    animated_button.props.default_color = current_theme.colors.primary
    animated_button.props.current_color = current_theme.colors.primary
    animated_button.props.default_text_color = current_theme.colors.text
    animated_button.props.current_text_color = current_theme.colors.text

    -- Update slider colors
    animated_slider.props.background_color = current_theme.colors.secondary
    animated_slider.props.active_color = current_theme.colors.accent

    -- Update checkbox colors
    animate_checkbox.props.box_color = current_theme.colors.primary
    animate_checkbox.props.check_color = current_theme.colors.accent
    animate_checkbox.props.text_color = current_theme.colors.text
end

function love.update(dt)
    doma.update(dt)

    -- Update window background color based on theme
    local theme_bg = doma.theme.get().colors.background
    love.graphics.setBackgroundColor(unpack(theme_bg))
end

function love.draw()
    doma.draw()
end

-- Input event handling
function love.mousepressed(x, y, button)
    event.trigger("mousepressed", x, y, button)
end

function love.mousemoved(x, y, dx, dy)
    event.trigger("mousemoved", x, y, dx, dy)
end

function love.mousereleased(x, y, button)
    event.trigger("mousereleased", x, y, button)
end

function love.keypressed(key)
    event.trigger("keypressed", key)
end

function love.textinput(t)
    event.trigger("textinput", t)
end

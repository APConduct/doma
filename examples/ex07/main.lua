local love = require("love")
local doma = require("doma")
local event = doma.event

local theme_buttons = {}
local animated_button
local animated_slider
local animate_checkbox
local main_container
local pulse_circle

-- Animation IDs
local animation_ids = {
    slider = nil,
    circle_radius = nil,
    circle_color = nil
}

function love.load()
    love.window.setTitle("DOMA UI - Theming & Animations")

    -- Create main container
    main_container = doma.container(50, 50, 600, 400)

    -- Add title
    local title = doma.element("text", {
        text = "Theme & Animation Demo",
        x = 20,
        y = 20,
        font_size = 24
    })
    main_container:add_element(title)

    -- Create theme selector buttons
    local theme_names = { "default", "dark", "light" }
    for i, theme_name in ipairs(theme_names) do
        local btn = doma.button(theme_name, 20 + (i - 1) * 120, 70, 100, 40, function()
            doma.theme.set(theme_name)
            update_theme_colors()
        end)
        table.insert(theme_buttons, btn)
        main_container:add_element(btn)
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
    main_container:add_element(animated_button)

    animated_slider = doma.slider(20, 220, 300, 0, 100, 50, {
        show_value = true
    })
    main_container:add_element(animated_slider)

    -- Create the pulsing circle element BEFORE any animation functions reference it
    pulse_circle = doma.element("circle", {
        x = 400,
        y = 220,
        radius = 40,
        color = { 0.4, 0.7, 1, 1 }
    })
    main_container:add_element(pulse_circle)

    -- Custom draw method for the circle
    pulse_circle.draw = function(self)
        -- Get backend from doma
        local backend = doma.backend
        local parent_x = self.props.parent and self.props.parent.props.x or 0
        local parent_y = self.props.parent and self.props.parent.props.y or 0

        if self.props.color then
            backend.graphics.set_color(unpack(self.props.color))
            backend.graphics.circle("fill",
                self.props.x + parent_x,
                self.props.y + parent_y,
                self.props.radius)
        end
    end

    -- Define animation functions
    local function reset_slider_animation()
        -- Cancel existing animation if it exists
        if animation_ids.slider then
            doma.animation.cancel(animation_ids.slider)
        end

        -- Reset to initial state
        animated_slider.props.value = 0

        -- Create new animation and store its ID
        animation_ids.slider = doma.animation.tween(animated_slider, "value", 0, 100, 3, {
            easing = "in_out_cubic",
            repeat_count = -1,
            repeat_delay = 0.5,
            on_update = function(target, progress)
                if target.props.on_change then
                    target.props.on_change(target.props.value)
                end
            end
        })

        return animation_ids.slider
    end

    local function reset_circle_animations()
        -- Cancel existing animations
        if animation_ids.circle_radius then
            doma.animation.cancel(animation_ids.circle_radius)
        end
        if animation_ids.circle_color then
            doma.animation.cancel(animation_ids.circle_color)
        end

        -- Reset to initial state
        pulse_circle.props.radius = 40
        pulse_circle.props.color = { 0.4, 0.7, 1, 1 }

        -- Create new animations and store their IDs
        animation_ids.circle_radius = doma.animation.keyframes(pulse_circle, "radius", {
            { time = 0,   value = 40 },
            { time = 0.5, value = 60 },
            { time = 1,   value = 40 }
        }, {
            duration = 2,
            repeat_count = -1,
            easing = "in_out_quad"
        })

        animation_ids.circle_color = doma.animation.keyframes(pulse_circle, "color", {
            { time = 0,    value = { 0.4, 0.7, 1, 1 } },
            { time = 0.33, value = { 1, 0.4, 0.7, 1 } },
            { time = 0.66, value = { 0.7, 1, 0.4, 1 } },
            { time = 1,    value = { 0.4, 0.7, 1, 1 } }
        }, {
            duration = 6,
            repeat_count = -1,
            easing = "linear"
        })

        return { radius = animation_ids.circle_radius, color = animation_ids.circle_color }
    end

    -- Helper function to stop all animations
    local function stop_all_animations()
        for id, _ in pairs(doma.animation.active) do
            doma.animation.cancel(id)
        end
        animation_ids = { slider = nil, circle_radius = nil, circle_color = nil }
    end

    -- Initialize animations function
    local function initialize_animations()
        reset_slider_animation()
        reset_circle_animations()
    end

    -- Add a checkbox to enable/disable animations
    animate_checkbox = doma.checkbox(20, 270, "Enable animations", true, {
        on_change = function(checked)
            if checked then
                initialize_animations()
            else
                stop_all_animations()
            end
        end
    })
    main_container:add_element(animate_checkbox)

    -- Now it's safe to initialize animations
    initialize_animations()

    -- Update colors based on current theme
    update_theme_colors()
end

-- Using the theme logic that was working perfectly
function update_theme_colors()
    local current_theme = doma.theme.get()
    local colors = current_theme.colors or {}
    local doma_utils = doma.utils -- Reference to utils to fix undefined global

    -- Update background color for the container
    if main_container then
        main_container.props.background_color = colors.background or { 0.2, 0.2, 0.2, 1 }
    end

    -- Update colors for various UI components
    for _, button in ipairs(theme_buttons) do
        if button.props.label == doma.theme.current then
            -- Highlight current theme button
            button.props.default_color = colors.accent or { 0.4, 0.7, 1, 1 }
            button.props.current_color = colors.accent or { 0.4, 0.7, 1, 1 }

            -- Get contrasting text color for accent
            local text_color = doma_utils.colors.contrast(
                colors.accent or { 0.4, 0.7, 1, 1 },
                { 0.9, 0.9, 0.9, 1 }, -- light
                { 0.1, 0.1, 0.1, 1 }  -- dark
            )

            button.props.default_text_color = text_color
            button.props.current_text_color = text_color
        else
            -- Regular appearance for other theme buttons
            button.props.default_color = colors.primary or { 1, 1, 1, 1 }
            button.props.current_color = colors.primary or { 1, 1, 1, 1 }

            -- Get contrasting text color for primary
            local text_color = doma_utils.colors.contrast(
                colors.primary or { 1, 1, 1, 1 },
                { 0.9, 0.9, 0.9, 1 }, -- light
                { 0.1, 0.1, 0.1, 1 }  -- dark
            )

            button.props.default_text_color = text_color
            button.props.current_text_color = text_color
        end
    end

    -- Update animated button colors
    animated_button.props.default_color = colors.primary or { 1, 1, 1, 1 }
    animated_button.props.current_color = colors.primary or { 1, 1, 1, 1 }

    -- Get contrasting text color for primary
    local button_text_color = doma_utils.colors.contrast(
        colors.primary or { 1, 1, 1, 1 },
        { 0.9, 0.9, 0.9, 1 }, -- light
        { 0.1, 0.1, 0.1, 1 }  -- dark
    )

    animated_button.props.default_text_color = button_text_color
    animated_button.props.current_text_color = button_text_color

    -- Update slider colors
    animated_slider.props.background_color = colors.secondary or { 0.8, 0.8, 0.8, 1 }
    animated_slider.props.active_color = colors.accent or { 0.4, 0.7, 1, 1 }

    -- Update checkbox colors
    animate_checkbox.props.box_color = colors.primary or { 1, 1, 1, 1 }
    animate_checkbox.props.check_color = colors.accent or { 0.4, 0.7, 1, 1 }

    -- Very important: select text color based on the container's background
    local container_bg = main_container and main_container.props.background_color or colors.background
    local checkbox_text_color = doma_utils.colors.contrast(
        container_bg or { 0.2, 0.2, 0.2, 1 },
        { 0.9, 0.9, 0.9, 1 }, -- light
        { 0.1, 0.1, 0.1, 1 }  -- dark
    )

    animate_checkbox.props.text_color = checkbox_text_color

    for _, child in ipairs(main_container.children) do
        if child.type == "text" then
            child.props.text_color = doma_utils.colors.contrast(
                main_container.props.background_color,
                { 0.9, 0.9, 0.9, 1 }, -- light text
                { 0.1, 0.1, 0.1, 1 }  -- dark text
            )
        end
    end
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

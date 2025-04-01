local love = require("love")
local doma = require("doma")
local event = doma.event

-- Variables to store created elements for reference
local red_slider, green_slider, blue_slider
local show_rgb_values, use_rounded_corners

function love.load()
    love.window.setTitle("DOMA UI - Sliders & Checkboxes")

    -- Create a container
    local controls = doma.container(50, 50, 400, 300)

    -- Create RGB sliders
    red_slider = doma.slider(20, 30, 200, 0, 255, 100, {
        show_value = true,
        active_color = { 0.8, 0.2, 0.2, 1 },
        on_change = update_color
    })

    green_slider = doma.slider(20, 70, 200, 0, 255, 150, {
        show_value = true,
        active_color = { 0.2, 0.8, 0.2, 1 },
        on_change = update_color
    })

    blue_slider = doma.slider(20, 110, 200, 0, 255, 200, {
        show_value = true,
        active_color = { 0.2, 0.2, 0.8, 1 },
        on_change = update_color
    })

    -- Create checkboxes
    show_rgb_values = doma.checkbox(20, 160, "Show RGB values", true, {
        on_change = function(checked)
            red_slider.props.show_value = checked
            green_slider.props.show_value = checked
            blue_slider.props.show_value = checked
        end
    })

    use_rounded_corners = doma.checkbox(20, 190, "Use rounded corners", true, {
        on_change = function(checked)
            -- Demo changing appearance based on checkbox
            if checked then
                controls.props.corner_radius = 10
            else
                controls.props.corner_radius = 0
            end
        end
    })

    -- Add the elements to the container
    controls:add_element(red_slider)
    controls:add_element(green_slider)
    controls:add_element(blue_slider)
    controls:add_element(show_rgb_values)
    controls:add_element(use_rounded_corners)

    -- Add a title label for the container
    local title = doma.element("text", {
        text = "Color Mixer",
        x = 20,
        y = 5,
        font_size = 18
    })
    controls:add_element(title)
end

function update_color()
    -- This function will update the background color based on slider values
    love.graphics.setBackgroundColor(
        red_slider.props.value / 255,
        green_slider.props.value / 255,
        blue_slider.props.value / 255
    )
end

function love.update(dt)
    doma.update(dt)
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

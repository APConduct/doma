local love = require("love")
local doma = require("doma")
local event = doma.event

local container, dropdown

function love.load()
    love.window.setTitle("DOMA UI - Dropdown & Layout")

    -- Create a container with a flex layout
    container = doma.container(50, 50, 500, 400)

    -- Create a title
    local title = doma.element("text", {
        text = "Layout Demo",
        x = 0,
        y = 0,
        font_size = 20
    })

    -- Create a dropdown
    dropdown = doma.dropdown(0, 0, 200, {
        "Row Layout", "Column Layout", "Grid Layout", "Flex Row", "Flex Column"
    }, 1, {
        on_select = function(option, index)
            update_layout(index)
        end
    })

    -- Create buttons to be arranged by layout
    local buttons = {}
    for i = 1, 8 do
        local btn = doma.button("Button " .. i, 0, 0, 80, 40, function()
            print("Button " .. i .. " clicked!")
        end)
        table.insert(buttons, btn)
        container:add_element(btn)
    end

    -- Store buttons for layout manipulation
    container.children_buttons = buttons

    -- Add title and dropdown to container
    container:add_element(title)
    container:add_element(dropdown)

    -- Initial layout
    update_layout(1)
end

function update_layout(layout_index)
    local title = container.children[1]
    local dropdown = container.children[2]
    local buttons = container.children_buttons

    -- Position title and dropdown with flex layout
    doma.layout.flex(10, 10, 480, 80, { title, dropdown }, {
        direction = "row",
        justify = "space-between",
        align = "center"
    })

    -- Apply different layouts to buttons based on selection
    if layout_index == 1 then
        -- Row layout
        doma.layout.row(10, 100, 10, buttons)
    elseif layout_index == 2 then
        -- Column layout
        doma.layout.column(10, 100, 10, buttons)
    elseif layout_index == 3 then
        -- Grid layout
        doma.layout.grid(10, 100, 10, 10, buttons)
    elseif layout_index == 4 then
        -- Flex row
        doma.layout.flex(10, 100, 480, 240, buttons, {
            direction = "row",
            justify = "space-around",
            align = "center",
            wrap = true
        })
    elseif layout_index == 5 then
        -- Flex column
        doma.layout.flex(10, 100, 480, 240, buttons, {
            direction = "column",
            justify = "space-between",
            align = "center"
        })
    end
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

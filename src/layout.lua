local layout = {}

function layout.row(x, y, spacing, elements)
    local offset_x = x
    for _, elem in ipairs(elements) do
        elem.props.x = offset_x
        elem.props.y = y
        offset_x = offset_x + (elem.props.w or 100) + spacing
    end
end

function layout.column(x, y, spacing, elements)
    local offset_y = y
    for _, elem in ipairs(elements) do
        elem.props.x = x
        elem.props.y = offset_y
        offset_y = offset_y + (elem.props.h or 100) + spacing
    end
end

function layout.grid(x, y, spacing_x, spacing_y, elements)
    local offset_x = x
    local offset_y = y
    for _, elem in ipairs(elements) do
        elem.props.x = offset_x
        elem.props.y = offset_y
        offset_x = offset_x + (elem.props.w or 100) + spacing_x
        if offset_x + (elem.props.w or 100) > x + 100 then
            offset_x = x
            offset_y = offset_y + (elem.props.h or 100) + spacing_y
        end
    end
end

function layout.flex(x, y, width, height, elements, options)
    options = options or {}
    local direction = options.direction or "row" -- "row" or "column"
    local spacing = options.spacing or 5
    local padding = options.padding or 0
    local justify = options.justify or "start" -- "start", "end", "center", "space-between", "space-around"
    local align = options.align or "start"     -- "start", "end", "center", "stretch"

    local start_x = x + padding
    local start_y = y + padding
    local usable_width = width - padding * 2
    local usable_height = height - padding * 2

    -- First pass: calculate total fixed size and count of flex elements
    local total_fixed_size = 0
    local flex_count = 0

    for _, elem in ipairs(elements) do
        if direction == "row" then
            if elem.props.flex then
                flex_count = flex_count + elem.props.flex
            else
                total_fixed_size = total_fixed_size + (elem.props.w or 0)
            end
        else -- column
            if elem.props.flex then
                flex_count = flex_count + elem.props.flex
            else
                total_fixed_size = total_fixed_size + (elem.props.h or 0)
            end
        end
    end

    -- Calculate spacing based on justify
    local total_spacing = spacing * (table.getn(elements) - 1)
    local flex_size = flex_count > 0 and
        ((direction == "row" and usable_width or usable_height) - total_fixed_size - total_spacing) / flex_count
        or 0

    -- Calculate starting position based on justify
    local starting_pos = 0
    if justify == "end" then
        starting_pos = (direction == "row" and usable_width or usable_height) - total_fixed_size -
            (flex_count * flex_size) - total_spacing
    elseif justify == "center" then
        starting_pos = ((direction == "row" and usable_width or usable_height) - total_fixed_size -
            (flex_count * flex_size) - total_spacing) / 2
    elseif justify == "space-between" and table.getn(elements) > 1 then
        spacing = ((direction == "row" and usable_width or usable_height) - total_fixed_size -
            (flex_count * flex_size)) / (table.getn(elements) - 1)
        total_spacing = spacing * (table.getn(elements) - 1)
    elseif justify == "space-around" and table.getn(elements) > 0 then
        spacing = ((direction == "row" and usable_width or usable_height) - total_fixed_size -
            (flex_count * flex_size)) / (table.getn(elements) * 2)
        starting_pos = spacing
        total_spacing = spacing * (table.getn(elements) * 2 - 2)
    end

    -- Second pass: position elements
    local current_pos = starting_pos

    for i, elem in ipairs(elements) do
        if direction == "row" then
            elem.props.x = start_x + current_pos

            -- Handle vertical alignment
            if align == "start" then
                elem.props.y = start_y
            elseif align == "end" then
                elem.props.y = start_y + usable_height - (elem.props.h or 0)
            elseif align == "center" then
                elem.props.y = start_y + (usable_height - (elem.props.h or 0)) / 2
            elseif align == "stretch" then
                elem.props.y = start_y
                elem.props.h = usable_height
            end

            -- Update width if element uses flex
            if elem.props.flex then
                elem.props.w = flex_size * elem.props.flex
            end

            -- Move to next position
            current_pos = current_pos + (elem.props.w or 0) + spacing
        else -- column
            elem.props.y = start_y + current_pos

            -- Handle horizontal alignment
            if align == "start" then
                elem.props.x = start_x
            elseif align == "end" then
                elem.props.x = start_x + usable_width - (elem.props.w or 0)
            elseif align == "center" then
                elem.props.x = start_x + (usable_width - (elem.props.w or 0)) / 2
            elseif align == "stretch" then
                elem.props.x = start_x
                elem.props.w = usable_width
            end

            -- Update height if element uses flex
            if elem.props.flex then
                elem.props.h = flex_size * elem.props.flex
            end

            -- Move to next position
            current_pos = current_pos + (elem.props.h or 0) + spacing
        end
    end
end

return layout

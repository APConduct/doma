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

return layout

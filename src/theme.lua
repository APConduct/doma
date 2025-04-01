local utils = require("src.utils")

local theme = {
    current = "default",
    themes = {}
}

-- Default theme
theme.themes.default = {
    colors = {
        primary = { 1, 1, 1, 1 },
        secondary = { 0.8, 0.8, 0.8, 1 },
        background = { 0.2, 0.2, 0.2, 1 },
        text = { 1, 1, 1, 1 },
        accent = { 0.4, 0.7, 1, 1 },
        success = { 0.2, 0.8, 0.2, 1 },
        warning = { 1, 0.8, 0.2, 1 },
        error = { 0.8, 0.2, 0.2, 1 },
    },

    -- Component-specific styles
    button = {
        padding = 5,
        corner_radius = 5,
        hover_brightness = 1.2,
    },

    textinput = {
        padding = 8,
        corner_radius = 4,
        border_width = 1,
    },

    slider = {
        track_height = 6,
        handle_size = 16,
    },

    checkbox = {
        size = 18,
        check_padding = 4,
    },

    container = {
        padding = 10,
        corner_radius = 3,
    },

    -- Typography
    typography = {
        font_size = 14,
        header_font_size = 24,
        font_family = nil, -- Will use default LÖVE font if nil
    }
}

-- Dark theme
theme.themes.dark = utils.clone(theme.themes.default)
theme.themes.dark.colors = {
    primary = { 0.9, 0.9, 0.9, 1 },
    secondary = { 0.7, 0.7, 0.7, 1 },
    background = { 0.1, 0.1, 0.1, 1 },
    text = { 0.9, 0.9, 0.9, 1 },
    accent = { 0.3, 0.6, 0.9, 1 },
    success = { 0.2, 0.7, 0.2, 1 },
    warning = { 0.9, 0.7, 0.2, 1 },
    error = { 0.7, 0.2, 0.2, 1 },
}

-- Light theme
theme.themes.light = utils.clone(theme.themes.default)
theme.themes.light.colors = {
    primary = { 0.1, 0.1, 0.1, 1 },
    secondary = { 0.3, 0.3, 0.3, 1 },
    background = { 0.9, 0.9, 0.9, 1 },
    text = { 0.1, 0.1, 0.1, 1 },
    accent = { 0.2, 0.5, 0.8, 1 },
    success = { 0, 0.6, 0, 1 },
    warning = { 0.8, 0.6, 0.1, 1 },
    error = { 0.7, 0.1, 0.1, 1 },
}

function theme.set(theme_name)
    if theme.themes[theme_name] then
        theme.current = theme_name
    else
        error("Theme '" .. theme_name .. "' doesn't exist")
    end
end

function theme.get()
    return theme.themes[theme.current]
end

function theme.add(name, theme_data)
    theme.themes[name] = theme_data
end

function theme.extend(name, base_theme, overrides)
    local base = theme.themes[base_theme]
    if not base then
        error("Base theme '" .. base_theme .. "' doesn't exist")
    end

    theme.themes[name] = utils.merge(utils.clone(base), overrides)
end

return theme

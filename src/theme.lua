local utils = require("src.utils")

local theme = {
    current = "default",
    themes = {}
}

local function calculate_derived_colors(colors)
    local light_text = { 0.9, 0.9, 0.9, 1 }
    local dark_text = { 0.2, 0.2, 0.2, 1 }

    return {
        primary_text = utils.colors.contrast(colors.primary, light_text, dark_text),
        secondary_text = utils.colors.contrast(colors.secondary, light_text, dark_text),
        accent_text = utils.colors.contrast(colors.accent, light_text, dark_text),
        background_text = utils.colors.contrast(colors.background, light_text, dark_text)
    }
end

-- Default theme
theme.themes.default = {
    colors = {
        primary = { 1, 1, 1, 1 },
        secondary = { 0.8, 0.8, 0.8, 1 },
        background = { 0.2, 0.2, 0.2, 1 },
        text = { 1, 1, 1, 1 },
        text_on_primary = { 0.1, 0.1, 0.1, 1 },    -- Auto-calculated below
        text_on_secondary = { 0.1, 0.1, 0.1, 1 },  -- Auto-calculated below
        text_on_background = { 0.9, 0.9, 0.9, 1 }, -- Auto-calculated below
        text_on_accent = { 0.1, 0.1, 0.1, 1 },     -- Auto-calculated below
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

-- Calculate derived colors for default theme
theme.themes.default.derived_colors = calculate_derived_colors(theme.themes.default.colors)

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

-- Calculate derived colors for dark theme
theme.themes.dark.derived_colors = calculate_derived_colors(theme.themes.dark.colors)


-- Light theme
theme.themes.light = utils.clone(theme.themes.default)
theme.themes.light.colors = {
    primary = { 0.3, 0.3, 0.3, 1 },
    secondary = { 0.3, 0.3, 0.3, 1 },
    background = { 0.9, 0.9, 0.9, 1 },
    text = { 0.1, 0.1, 0.1, 1 },
    accent = { 0.2, 0.5, 0.8, 1 },
    success = { 0, 0.6, 0, 1 },
    warning = { 0.8, 0.6, 0.1, 1 },
    error = { 0.7, 0.1, 0.1, 1 },
}

-- Calculate derived colors for light theme
theme.themes.light.derived_colors = calculate_derived_colors(theme.themes.light.colors)
local original_set = theme.set

function theme.get()
    return theme.themes[theme.current] or theme.themes.default
end

function theme.extend(name, base_theme, overrides)
    local base = theme.themes[base_theme]
    if not base then
        error("Base theme '" .. base_theme .. "' doesn't exist")
    end

    theme.themes[name] = utils.merge(utils.clone(base), overrides)
end

function theme.get_contrasting_text(bg_color, options)
    options = options or {}
    local light_color = options.light_color or { 0.9, 0.9, 0.9, 1 }
    local dark_color = options.dark_color or { 0.1, 0.1, 0.1, 1 }

    return utils.colors.contrast(bg_color, light_color, dark_color)
end

function theme.get_text_color(background_color)
    local light_text = { 0.9, 0.9, 0.9, 1 }
    local dark_text = { 0.2, 0.2, 0.2, 1 }
    local luminance = 0.299 * background_color[1] + 0.587 * background_color[2] + 0.114 * background_color[3]
    if luminance > 0.5 then
        return dark_text  -- Dark text for light backgrounds
    else
        return light_text -- Light text for dark backgrounds
    end
end

local function add_derived_colors(theme_data)
    -- Make sure colors exist
    theme_data.colors = theme_data.colors or {
        primary = { 1, 1, 1, 1 },
        secondary = { 0.8, 0.8, 0.8, 1 },
        background = { 0.2, 0.2, 0.2, 1 },
        text = { 1, 1, 1, 1 },
        accent = { 0.4, 0.7, 1, 1 }
    }

    -- Create derived colors based on contrast
    theme_data.derived_colors = {
        primary_text = theme.get_text_color(theme_data.colors.primary),
        secondary_text = theme.get_text_color(theme_data.colors.secondary),
        accent_text = theme.get_text_color(theme_data.colors.accent),
        background_text = theme.get_text_color(theme_data.colors.background or { 0.2, 0.2, 0.2, 1 }),

        -- Add more if needed
        success_text = theme_data.colors.success and theme.get_text_color(theme_data.colors.success) or
            { 0.1, 0.1, 0.1, 1 },
        warning_text = theme_data.colors.warning and theme.get_text_color(theme_data.colors.warning) or
            { 0.1, 0.1, 0.1, 1 },
        error_text = theme_data.colors.error and theme.get_text_color(theme_data.colors.error) or { 0.9, 0.9, 0.9, 1 }
    }

    return theme_data
end

theme.themes.default = add_derived_colors(theme.themes.default)
theme.themes.dark = add_derived_colors(theme.themes.dark)
theme.themes.light = add_derived_colors(theme.themes.light)

function theme.set(theme_name)
    if theme.themes[theme_name] then
        -- Make sure derived colors are present
        add_derived_colors(theme.themes[theme_name])
        theme.current = theme_name
    else
        error("Theme '" .. theme_name .. "' doesn't exist")
    end
end

local original_add = theme.add
function theme.add(name, theme_data)
    theme.themes[name] = add_derived_colors(theme_data)
end

theme.themes.default = add_derived_colors(theme.themes.default)
theme.themes.dark = add_derived_colors(theme.themes.dark)
theme.themes.light = add_derived_colors(theme.themes.light)

theme.current = "default"


return theme

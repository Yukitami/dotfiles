local gears = require("gears")
local wibox = require("wibox")
local beautiful = require("beautiful")
local helpers = require("helpers")

-- Modern UI Design System
-- Centralized styling following contemporary UX/UI trends
-- ===================================================================

local modern_ui = {}

-- Design tokens
-- ===================================================================
modern_ui.spacing = {
    none = dpi(0),
    xs = dpi(4),
    sm = dpi(8),
    md = dpi(12),
    lg = dpi(16),
    xl = dpi(20),
    xxl = dpi(24),
    xxxl = dpi(32),
}

modern_ui.radius = {
    sm = dpi(4),
    md = dpi(8),
    lg = dpi(12),
    xl = dpi(16),
    full = dpi(9999),  -- Circular
}

modern_ui.elevation = {
    none = { border_width = dpi(0), border_color = "#00000000" },
    low = { border_width = dpi(1), border_color = x.color8 .. "20" },
    medium = { border_width = dpi(1), border_color = x.color8 .. "40" },
    high = { border_width = dpi(2), border_color = x.color8 .. "60" },
}

modern_ui.typography = {
    -- Display sizes for large headers
    display_lg = { font = "sans extra bold 28", line_height = 1.2 },
    display_md = { font = "sans extra bold 24", line_height = 1.2 },
    display_sm = { font = "sans bold 20", line_height = 1.3 },

    -- Heading sizes
    heading_lg = { font = "sans bold 16", line_height = 1.3 },
    heading_md = { font = "sans bold 12", line_height = 1.4 },
    heading_sm = { font = "sans bold 10", line_height = 1.4 },

    -- Body text
    body_lg = { font = "sans 11", line_height = 1.5 },
    body_md = { font = "sans 9", line_height = 1.5 },
    body_sm = { font = "sans 8", line_height = 1.5 },

    -- Caption/small text
    caption = { font = "sans 7", line_height = 1.4 },

    -- Icon sizes
    icon_xxl = { font = "icomoon 32" },
    icon_xl = { font = "icomoon 24" },
    icon_lg = { font = "icomoon 18" },
    icon_md = { font = "icomoon 14" },
    icon_sm = { font = "icomoon 12" },
    icon_xs = { font = "icomoon 10" },
}

modern_ui.colors = {
    -- Surface colors
    surface_0 = x.color0,  -- Base surface
    surface_1 = x.color0 .. "CC",  -- Slightly transparent
    surface_2 = x.color0 .. "99",  -- More transparent

    -- Text colors
    text_primary = x.foreground,
    text_secondary = x.color7,
    text_tertiary = x.color8,

    -- Accent colors (from xresources)
    accent_primary = x.color4,
    accent_secondary = x.color5,
    accent_success = x.color2,
    accent_warning = x.color3,
    accent_error = x.color1,
    accent_info = x.color6,
}

-- Modern Card Component
-- ===================================================================
function modern_ui.create_card(args)
    args = args or {}

    local content = args.content or wibox.widget.textbox("Empty card")
    local padding = args.padding or modern_ui.spacing.md
    local bg_color = args.bg_color or modern_ui.colors.surface_0
    local border = args.border or modern_ui.elevation.low
    local radius = args.radius or modern_ui.radius.lg
    local hover_effect = args.hover_effect ~= false  -- Default true
    local width = args.width
    local height = args.height

    local card_bg = wibox.widget {
        {
            content,
            margins = padding,
            widget = wibox.container.margin,
        },
        bg = bg_color,
        shape = helpers.rrect(radius),
        border_width = border.border_width,
        border_color = border.border_color,
        widget = wibox.container.background,
    }

    if width then card_bg.forced_width = width end
    if height then card_bg.forced_height = height end

    -- Hover effect
    if hover_effect then
        local original_bg = bg_color
        local original_border = border.border_color
        local hover_bg = x.color8 .. "10"

        card_bg:connect_signal("mouse::enter", function()
            card_bg.bg = hover_bg
            card_bg.border_color = x.color8 .. "60"
        end)

        card_bg:connect_signal("mouse::leave", function()
            card_bg.bg = original_bg
            card_bg.border_color = original_border
        end)
    end

    return card_bg
end

-- Modern Button Component
-- ===================================================================
function modern_ui.create_button(args)
    args = args or {}

    local icon = args.icon
    local text = args.text
    local on_click = args.on_click
    local style = args.style or "primary"  -- primary, secondary, ghost, danger
    local size = args.size or "md"  -- sm, md, lg
    local shape_type = args.shape or "rounded"  -- rounded, circular

    -- Size configurations
    local size_config = {
        sm = { padding = modern_ui.spacing.sm, icon_size = modern_ui.typography.icon_sm.font, text_size = modern_ui.typography.body_sm.font },
        md = { padding = modern_ui.spacing.md, icon_size = modern_ui.typography.icon_md.font, text_size = modern_ui.typography.body_md.font },
        lg = { padding = modern_ui.spacing.lg, icon_size = modern_ui.typography.icon_lg.font, text_size = modern_ui.typography.body_lg.font },
    }

    local config = size_config[size]

    -- Style configurations
    local style_config = {
        primary = {
            bg = modern_ui.colors.accent_primary .. "30",
            fg = modern_ui.colors.accent_primary,
            hover_bg = modern_ui.colors.accent_primary .. "50",
            border = modern_ui.colors.accent_primary .. "40",
        },
        secondary = {
            bg = modern_ui.colors.surface_0,
            fg = modern_ui.colors.text_primary,
            hover_bg = x.color8 .. "20",
            border = x.color8 .. "30",
        },
        ghost = {
            bg = "#00000000",
            fg = modern_ui.colors.text_secondary,
            hover_bg = x.color8 .. "15",
            border = "#00000000",
        },
        danger = {
            bg = modern_ui.colors.accent_error .. "20",
            fg = modern_ui.colors.accent_error,
            hover_bg = modern_ui.colors.accent_error .. "40",
            border = modern_ui.colors.accent_error .. "30",
        },
    }

    local colors = style_config[style]

    -- Button content
    local content_widgets = {}

    if icon then
        table.insert(content_widgets, wibox.widget {
            markup = helpers.colorize_text(icon, colors.fg),
            font = config.icon_size,
            align = "center",
            valign = "center",
            widget = wibox.widget.textbox,
        })
    end

    if text then
        table.insert(content_widgets, wibox.widget {
            markup = "<span foreground='" .. colors.fg .. "'>" .. text .. "</span>",
            font = config.text_size,
            align = "center",
            valign = "center",
            widget = wibox.widget.textbox,
        })
    end

    local button_content = wibox.widget {
        layout = wibox.layout.fixed.horizontal,
        spacing = modern_ui.spacing.sm,
    }

    for _, w in ipairs(content_widgets) do
        button_content:add(w)
    end

    -- Button container
    local button = wibox.widget {
        {
            {
                button_content,
                widget = wibox.container.place,
            },
            margins = config.padding,
            widget = wibox.container.margin,
        },
        bg = colors.bg,
        shape = shape_type == "circular" and gears.shape.circle or helpers.rrect(modern_ui.radius.md),
        border_width = dpi(1),
        border_color = colors.border,
        widget = wibox.container.background,
    }

    -- Hover effects
    button:connect_signal("mouse::enter", function()
        button.bg = colors.hover_bg
    end)

    button:connect_signal("mouse::leave", function()
        button.bg = colors.bg
    end)

    -- Click handler
    if on_click then
        button:buttons(gears.table.join(
            awful.button({}, 1, on_click)
        ))
    end

    helpers.add_hover_cursor(button, "hand1")

    return button
end

-- Modern Badge/Chip Component
-- ===================================================================
function modern_ui.create_badge(args)
    args = args or {}

    local text = args.text or ""
    local icon = args.icon
    local color = args.color or modern_ui.colors.accent_primary
    local size = args.size or "sm"  -- xs, sm, md

    local size_config = {
        xs = { padding = dpi(4), font = modern_ui.typography.caption.font, icon_font = modern_ui.typography.icon_xs.font },
        sm = { padding = dpi(6), font = modern_ui.typography.body_sm.font, icon_font = modern_ui.typography.icon_sm.font },
        md = { padding = dpi(8), font = modern_ui.typography.body_md.font, icon_font = modern_ui.typography.icon_md.font },
    }

    local config = size_config[size]

    local content_widgets = {}

    if icon then
        table.insert(content_widgets, wibox.widget {
            markup = helpers.colorize_text(icon, color),
            font = config.icon_font,
            widget = wibox.widget.textbox,
        })
    end

    if text ~= "" then
        table.insert(content_widgets, wibox.widget {
            markup = "<span foreground='" .. color .. "'>" .. text .. "</span>",
            font = config.font,
            widget = wibox.widget.textbox,
        })
    end

    local badge_content = wibox.widget {
        layout = wibox.layout.fixed.horizontal,
        spacing = modern_ui.spacing.xs,
    }

    for _, w in ipairs(content_widgets) do
        badge_content:add(w)
    end

    return wibox.widget {
        {
            badge_content,
            margins = config.padding,
            widget = wibox.container.margin,
        },
        bg = color .. "20",
        shape = helpers.rrect(modern_ui.radius.full),
        widget = wibox.container.background,
    }
end

-- Modern Avatar Component
-- ===================================================================
function modern_ui.create_avatar(args)
    args = args or {}

    local image = args.image
    local icon = args.icon
    local text = args.text
    local size = args.size or "md"  -- sm, md, lg, xl
    local shape_type = args.shape or "circular"  -- circular, rounded

    local size_config = {
        sm = dpi(32),
        md = dpi(48),
        lg = dpi(64),
        xl = dpi(96),
        xxl = dpi(128),
    }

    local avatar_size = size_config[size]

    local content
    if image then
        content = wibox.widget {
            image = image,
            resize = true,
            widget = wibox.widget.imagebox,
        }
    elseif icon then
        content = wibox.widget {
            markup = helpers.colorize_text(icon, modern_ui.colors.accent_primary),
            font = "icomoon " .. math.floor(avatar_size / 2),
            align = "center",
            valign = "center",
            widget = wibox.widget.textbox,
        }
    elseif text then
        content = wibox.widget {
            markup = "<span foreground='" .. modern_ui.colors.text_primary .. "'><b>" .. text .. "</b></span>",
            font = "sans bold " .. math.floor(avatar_size / 3),
            align = "center",
            valign = "center",
            widget = wibox.widget.textbox,
        }
    end

    return wibox.widget {
        {
            content,
            widget = wibox.container.place,
        },
        forced_width = avatar_size,
        forced_height = avatar_size,
        shape = shape_type == "circular" and gears.shape.circle or helpers.rrect(modern_ui.radius.lg),
        bg = modern_ui.colors.surface_0,
        border_width = dpi(2),
        border_color = x.color8 .. "30",
        widget = wibox.container.background,
    }
end

-- Modern Progress Bar Component
-- ===================================================================
function modern_ui.create_progress_bar(args)
    args = args or {}

    local value = args.value or 0
    local max_value = args.max_value or 100
    local color = args.color or modern_ui.colors.accent_primary
    local height = args.height or dpi(8)
    local width = args.width
    local show_text = args.show_text

    local bar = wibox.widget {
        max_value = max_value,
        value = value,
        color = color,
        background_color = x.color8 .. "20",
        shape = helpers.rrect(modern_ui.radius.full),
        bar_shape = helpers.rrect(modern_ui.radius.full),
        forced_height = height,
        forced_width = width,
        widget = wibox.widget.progressbar,
    }

    if show_text then
        return wibox.widget {
            {
                bar,
                {
                    markup = "<span foreground='" .. modern_ui.colors.text_secondary .. "'>" .. value .. "%</span>",
                    font = modern_ui.typography.caption.font,
                    align = "right",
                    widget = wibox.widget.textbox,
                },
                spacing = modern_ui.spacing.sm,
                layout = wibox.layout.fixed.horizontal,
            },
            layout = wibox.layout.fixed.vertical,
        }
    end

    return bar
end

-- Modern Divider Component
-- ===================================================================
function modern_ui.create_divider(args)
    args = args or {}

    local orientation = args.orientation or "horizontal"  -- horizontal, vertical
    local color = args.color or x.color8 .. "20"
    local thickness = args.thickness or dpi(1)

    if orientation == "horizontal" then
        return wibox.widget {
            bg = color,
            forced_height = thickness,
            widget = wibox.container.background,
        }
    else
        return wibox.widget {
            bg = color,
            forced_width = thickness,
            widget = wibox.container.background,
        }
    end
end

return modern_ui

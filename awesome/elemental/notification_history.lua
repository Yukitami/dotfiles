local awful = require("awful")
local gears = require("gears")
local wibox = require("wibox")
local beautiful = require("beautiful")
local naughty = require("naughty")

local helpers = require("helpers")
local history = require("notifications.history")

-- Modern Notification History Widget
-- Following contemporary UX/UI trends: card-based design, better spacing,
-- improved typography hierarchy, smooth interactions, and visual depth
-- ===================================================================

-- Create a single notification card with modern styling
local function create_notification_item(notification_data, index)
    local icon_font = "icomoon 14"

    -- Icon mapping with modern design
    local app_icons = {
        ['battery'] = "",
        ['charger'] = "",
        ['volume'] = "",
        ['brightness'] = "",
        ['screenshot'] = "",
        ['mpd'] = "",
        ['keyboard'] = "",
        ['email'] = "",
        ['notification'] = ""
    }

    local urgency_colors = {
        ['low'] = x.color2,
        ['normal'] = x.color4,
        ['critical'] = x.color11,
    }

    local icon_text = app_icons[notification_data.app_name] or app_icons['notification']
    local color = urgency_colors[notification_data.urgency] or x.color4
    local time_str = history.get_time_string(notification_data.timestamp)

    -- Modern card design with icon badge
    local icon_badge = wibox.widget {
        {
            {
                markup = helpers.colorize_text(icon_text, color),
                font = icon_font,
                align = "center",
                valign = "center",
                widget = wibox.widget.textbox,
            },
            margins = dpi(8),
            widget = wibox.container.margin,
        },
        bg = color .. "22",  -- 22 = ~13% opacity for subtle background
        shape = gears.shape.circle,
        forced_width = dpi(40),
        forced_height = dpi(40),
        widget = wibox.container.background,
    }

    -- Content with improved typography hierarchy
    local content = wibox.widget {
        {
            {
                -- Title with better contrast
                markup = "<span foreground='" .. x.foreground .. "'><b>" ..
                         gears.string.xml_escape(notification_data.title) .. "</b></span>",
                font = "sans bold 9",
                widget = wibox.widget.textbox,
            },
            -- Message with secondary text color
            {
                markup = "<span foreground='" .. x.color7 .. "'>" ..
                         gears.string.xml_escape(notification_data.message):sub(1, 45) ..
                         (notification_data.message:len() > 45 and "..." or "") .. "</span>",
                font = "sans 8",
                widget = wibox.widget.textbox,
            },
            spacing = dpi(3),
            layout = wibox.layout.fixed.vertical,
        },
        left = dpi(12),
        right = dpi(8),
        widget = wibox.container.margin,
    }

    -- Timestamp badge
    local time_badge = wibox.widget {
        {
            markup = "<span foreground='" .. x.color8 .. "'>" .. time_str .. "</span>",
            font = "sans 7",
            align = "right",
            valign = "center",
            widget = wibox.widget.textbox,
        },
        right = dpi(8),
        widget = wibox.container.margin,
    }

    -- Card layout
    local card_content = wibox.widget {
        {
            icon_badge,
            {
                content,
                time_badge,
                layout = wibox.layout.align.horizontal,
            },
            spacing = dpi(0),
            layout = wibox.layout.fixed.horizontal,
        },
        margins = dpi(10),
        widget = wibox.container.margin,
    }

    -- Modern card container with subtle border and background
    local card = wibox.widget {
        card_content,
        bg = x.color0,
        shape = helpers.rrect(dpi(8)),
        border_width = dpi(1),
        border_color = x.color8 .. "30",  -- Subtle border
        widget = wibox.container.background,
    }

    -- Smooth hover animations
    local original_bg = x.color0
    local hover_bg = x.color8 .. "20"

    card:connect_signal("mouse::enter", function()
        card.bg = hover_bg
        card.border_color = color .. "60"
        icon_badge.bg = color .. "30"
    end)

    card:connect_signal("mouse::leave", function()
        card.bg = original_bg
        card.border_color = x.color8 .. "30"
        icon_badge.bg = color .. "22"
    end)

    -- Click to remove with visual feedback
    card:buttons(gears.table.join(
        awful.button({}, 1, function()
            -- Fade out animation effect (instant for now, can be animated)
            card.opacity = 0.5
            gears.timer.start_new(0.1, function()
                history.remove(index)
                return false
            end)
        end)
    ))

    helpers.add_hover_cursor(card, "hand1")

    return card
end

-- Modern empty state
local function create_empty_state()
    return wibox.widget {
        {
            {
                {
                    markup = helpers.colorize_text("", x.color8),
                    font = "icomoon 32",
                    align = "center",
                    valign = "center",
                    widget = wibox.widget.textbox,
                },
                {
                    markup = "<span foreground='" .. x.color8 .. "'>No notifications yet</span>",
                    font = "sans 10",
                    align = "center",
                    widget = wibox.widget.textbox,
                },
                {
                    markup = "<span foreground='" .. x.color8 .. "' size='small'>You're all caught up!</span>",
                    font = "sans 8",
                    align = "center",
                    widget = wibox.widget.textbox,
                },
                spacing = dpi(8),
                layout = wibox.layout.fixed.vertical,
            },
            margins = dpi(20),
            widget = wibox.container.margin,
        },
        forced_height = dpi(120),
        widget = wibox.container.place,
    }
end

-- Notification list container
local notification_list = wibox.widget {
    spacing = dpi(8),  -- More breathing room between cards
    layout = wibox.layout.fixed.vertical,
}

local function update_notification_list()
    notification_list:reset()

    if #history.notifications == 0 then
        notification_list:add(create_empty_state())
    else
        -- Show last 5 notifications
        local max_display = math.min(5, #history.notifications)
        for i = 1, max_display do
            notification_list:add(create_notification_item(history.notifications[i], i))
        end

        -- "View more" indicator if there are additional notifications
        if #history.notifications > max_display then
            local more_count = #history.notifications - max_display
            local more_indicator = wibox.widget {
                {
                    {
                        markup = "<span foreground='" .. x.color4 .. "'>+" .. more_count ..
                                 " more notification" .. (more_count > 1 and "s" or "") .. "</span>",
                        font = "sans 8",
                        align = "center",
                        widget = wibox.widget.textbox,
                    },
                    margins = dpi(8),
                    widget = wibox.container.margin,
                },
                bg = x.color4 .. "15",
                shape = helpers.rrect(dpi(6)),
                widget = wibox.container.background,
            }
            notification_list:add(more_indicator)
        end
    end
end

-- Modern header design
local clear_button = wibox.widget {
    {
        {
            markup = helpers.colorize_text("", x.color9),
            font = "icomoon 10",
            align = "center",
            valign = "center",
            widget = wibox.widget.textbox,
        },
        margins = dpi(6),
        widget = wibox.container.margin,
    },
    bg = x.color9 .. "15",
    shape = gears.shape.circle,
    forced_width = dpi(28),
    forced_height = dpi(28),
    widget = wibox.container.background,
}

-- Clear button hover effect
clear_button:connect_signal("mouse::enter", function()
    clear_button.bg = x.color9 .. "30"
end)
clear_button:connect_signal("mouse::leave", function()
    clear_button.bg = x.color9 .. "15"
end)

clear_button:buttons(gears.table.join(
    awful.button({}, 1, function()
        history.clear()
    end)
))

helpers.add_hover_cursor(clear_button, "hand1")

local header = wibox.widget {
    {
        {
            {
                markup = helpers.colorize_text("", x.color4),
                font = "icomoon 11",
                widget = wibox.widget.textbox,
            },
            {
                markup = "<span foreground='" .. x.foreground .. "'> Notifications</span>",
                font = "sans bold 10",
                widget = wibox.widget.textbox,
            },
            spacing = dpi(6),
            layout = wibox.layout.fixed.horizontal,
        },
        clear_button,
        layout = wibox.layout.align.horizontal,
    },
    bottom = dpi(8),
    widget = wibox.container.margin,
}

-- Divider line for visual separation
local divider = wibox.widget {
    bg = x.color8 .. "20",
    forced_height = dpi(1),
    widget = wibox.container.background,
}

-- Main notification history widget with modern spacing
notification_history_widget = wibox.widget {
    {
        header,
        divider,
        {
            notification_list,
            top = dpi(12),
            widget = wibox.container.margin,
        },
        spacing = dpi(8),
        layout = wibox.layout.fixed.vertical,
    },
    top = dpi(15),
    bottom = dpi(15),
    widget = wibox.container.margin,
}

-- Update list when history changes
awesome.connect_signal("notification_history::updated", function()
    update_notification_list()
end)

-- Initialize with current state
update_notification_list()

-- Make it globally accessible for sidebar integration
return notification_history_widget

local awful = require("awful")
local gears = require("gears")
local wibox = require("wibox")
local beautiful = require("beautiful")
local naughty = require("naughty")

local helpers = require("helpers")
local history = require("notifications.history")

-- Notification history widget for sidebar
-- ===================================================================

-- Create a single notification item widget
local function create_notification_item(notification_data, index)
    local icon_font = "icomoon 12"

    -- Default icon mapping (similar to amarena theme)
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

    local item = wibox.widget {
        {
            {
                {
                    -- Icon
                    markup = helpers.colorize_text(icon_text, color),
                    font = icon_font,
                    align = "center",
                    valign = "center",
                    widget = wibox.widget.textbox,
                },
                forced_width = dpi(28),
                bg = x.background,
                widget = wibox.container.background,
            },
            {
                {
                    -- Title
                    {
                        markup = "<b>" .. gears.string.xml_escape(notification_data.title) .. "</b>",
                        font = "sans bold 8",
                        widget = wibox.widget.textbox,
                    },
                    -- Message (truncated)
                    {
                        markup = gears.string.xml_escape(notification_data.message):sub(1, 50) ..
                                 (notification_data.message:len() > 50 and "..." or ""),
                        font = "sans 7",
                        widget = wibox.widget.textbox,
                    },
                    spacing = dpi(1),
                    layout = wibox.layout.fixed.vertical,
                },
                left = dpi(8),
                right = dpi(5),
                widget = wibox.container.margin,
            },
            {
                -- Timestamp
                markup = helpers.colorize_text(time_str, x.color8),
                font = "sans 6",
                align = "right",
                valign = "top",
                widget = wibox.widget.textbox,
            },
            layout = wibox.layout.align.horizontal,
        },
        margins = dpi(4),
        widget = wibox.container.margin,
    }

    local container = wibox.widget {
        item,
        bg = x.color0,
        shape = helpers.rrect(dpi(4)),
        widget = wibox.container.background,
    }

    -- Hover effect
    container:connect_signal("mouse::enter", function()
        container.bg = x.color8 .. "40"
    end)
    container:connect_signal("mouse::leave", function()
        container.bg = x.color0
    end)

    -- Click to remove
    container:buttons(gears.table.join(
        awful.button({}, 1, function()
            history.remove(index)
        end)
    ))

    return container
end

-- Create the scrollable notification list
local notification_list = wibox.widget {
    spacing = dpi(4),
    layout = wibox.layout.fixed.vertical,
}

local function update_notification_list()
    notification_list:reset()

    if #history.notifications == 0 then
        notification_list:add(wibox.widget {
            {
                markup = helpers.colorize_text("No notifications", x.color8),
                font = "sans 9",
                align = "center",
                valign = "center",
                widget = wibox.widget.textbox,
            },
            forced_height = dpi(40),
            widget = wibox.container.place,
        })
    else
        -- Show only the last 5 notifications to keep it compact
        local max_display = math.min(5, #history.notifications)
        for i = 1, max_display do
            notification_list:add(create_notification_item(history.notifications[i], i))
        end

        -- If there are more notifications, show a count
        if #history.notifications > max_display then
            notification_list:add(wibox.widget {
                {
                    markup = helpers.colorize_text(
                        string.format("+%d more", #history.notifications - max_display),
                        x.color8
                    ),
                    font = "sans 7",
                    align = "center",
                    widget = wibox.widget.textbox,
                },
                top = dpi(5),
                widget = wibox.container.margin,
            })
        end
    end
end

-- Header with title and clear button
local header = wibox.widget {
    {
        {
            markup = helpers.colorize_text("", x.color4),
            font = "icomoon 10",
            widget = wibox.widget.textbox,
        },
        {
            markup = " Notifications",
            font = "sans bold 9",
            widget = wibox.widget.textbox,
        },
        spacing = dpi(5),
        layout = wibox.layout.fixed.horizontal,
    },
    {
        {
            markup = helpers.colorize_text("", x.color9),
            font = "icomoon 9",
            widget = wibox.widget.textbox,
        },
        buttons = gears.table.join(
            awful.button({}, 1, function()
                history.clear()
            end)
        ),
        widget = wibox.container.background,
    },
    layout = wibox.layout.align.horizontal,
}

-- Add hover cursor to clear button
helpers.add_hover_cursor(header:get_children_by_id('')[1] or header, "hand1")

-- Main notification history widget
notification_history_widget = wibox.widget {
    {
        header,
        {
            notification_list,
            top = dpi(8),
            widget = wibox.container.margin,
        },
        spacing = dpi(5),
        layout = wibox.layout.fixed.vertical,
    },
    top = dpi(10),
    bottom = dpi(10),
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

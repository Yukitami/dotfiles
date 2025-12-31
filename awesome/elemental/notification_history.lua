local awful = require("awful")
local gears = require("gears")
local wibox = require("wibox")
local beautiful = require("beautiful")
local naughty = require("naughty")

local helpers = require("helpers")
local history = require("notifications.history")

-- Notification history panel
-- ===================================================================

local panel_visible = false
local panel_width = dpi(500)
local panel_height = dpi(600)

-- Create the notification history panel
local function create_notification_item(notification_data, index)
    local icon_font = "icomoon 16"

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
                    {
                        markup = helpers.colorize_text(icon_text, color),
                        font = icon_font,
                        align = "center",
                        valign = "center",
                        widget = wibox.widget.textbox,
                    },
                    forced_width = dpi(40),
                    bg = x.background,
                    widget = wibox.container.background,
                },
                {
                    {
                        -- Title and message
                        {
                            {
                                markup = "<b>" .. gears.string.xml_escape(notification_data.title) .. "</b>",
                                font = "sans bold 10",
                                widget = wibox.widget.textbox,
                            },
                            {
                                markup = gears.string.xml_escape(notification_data.message),
                                font = "sans 9",
                                widget = wibox.widget.textbox,
                            },
                            spacing = dpi(2),
                            layout = wibox.layout.fixed.vertical,
                        },
                        left = dpi(10),
                        right = dpi(10),
                        widget = wibox.container.margin,
                    },
                    {
                        -- Timestamp
                        {
                            markup = helpers.colorize_text(time_str, x.color8),
                            font = "sans 8",
                            align = "right",
                            valign = "top",
                            widget = wibox.widget.textbox,
                        },
                        top = dpi(2),
                        right = dpi(10),
                        widget = wibox.container.margin,
                    },
                    layout = wibox.layout.align.horizontal,
                },
                layout = wibox.layout.fixed.horizontal,
            },
            margins = dpi(8),
            widget = wibox.container.margin,
        },
        bg = x.color0,
        shape = helpers.rrect(dpi(6)),
        widget = wibox.container.background,
    }

    -- Hover effect
    item:connect_signal("mouse::enter", function()
        item.bg = x.color8 .. "40"
    end)
    item:connect_signal("mouse::leave", function()
        item.bg = x.color0
    end)

    -- Click to remove
    item:buttons(gears.table.join(
        awful.button({}, 1, function()
            history.remove(index)
        end),
        awful.button({}, 3, function()
            history.remove(index)
        end)
    ))

    return item
end

local notification_list = wibox.widget {
    spacing = dpi(8),
    layout = wibox.layout.fixed.vertical,
}

local scrollbox = wibox.widget {
    notification_list,
    step_function = wibox.container.scroll.step_functions.waiting_nonlinear_back_and_forth,
    fps = 60,
    speed = 75,
    layout = wibox.container.scroll.vertical,
}

local function update_notification_list()
    notification_list:reset()

    if #history.notifications == 0 then
        notification_list:add(wibox.widget {
            {
                markup = helpers.colorize_text("No notifications", x.color8),
                font = "sans 12",
                align = "center",
                valign = "center",
                widget = wibox.widget.textbox,
            },
            forced_height = dpi(100),
            widget = wibox.container.place,
        })
    else
        for i, notification_data in ipairs(history.notifications) do
            notification_list:add(create_notification_item(notification_data, i))
        end
    end
end

-- Header
local header = wibox.widget {
    {
        {
            {
                markup = helpers.colorize_text("", x.color4),
                font = "icomoon 14",
                widget = wibox.widget.textbox,
            },
            {
                markup = " Notification History",
                font = "sans bold 12",
                widget = wibox.widget.textbox,
            },
            spacing = dpi(8),
            layout = wibox.layout.fixed.horizontal,
        },
        {
            {
                markup = helpers.colorize_text("", x.color9),
                font = "icomoon 12",
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
    },
    left = dpi(15),
    right = dpi(15),
    top = dpi(15),
    bottom = dpi(10),
    widget = wibox.container.margin,
}

-- Main panel widget
local panel_widget = wibox.widget {
    {
        header,
        {
            scrollbox,
            margins = dpi(15),
            widget = wibox.container.margin,
        },
        layout = wibox.layout.fixed.vertical,
    },
    bg = x.color0,
    shape = helpers.rrect(dpi(10)),
    border_width = dpi(2),
    border_color = x.color8,
    widget = wibox.container.background,
}

-- Create the popup
local notification_history_popup = awful.popup {
    widget = panel_widget,
    visible = false,
    ontop = true,
    placement = awful.placement.centered,
    shape = helpers.rrect(dpi(10)),
    bg = "#00000000",
    preferred_positions = "top",
    preferred_anchors = "middle",
    width = panel_width,
    height = panel_height,
}

-- Toggle function
local function toggle()
    if panel_visible then
        notification_history_popup.visible = false
        panel_visible = false
    else
        update_notification_list()
        notification_history_popup.visible = true
        panel_visible = true
    end
end

-- Hide function
local function hide()
    notification_history_popup.visible = false
    panel_visible = false
end

-- Show function
local function show()
    update_notification_list()
    notification_history_popup.visible = true
    panel_visible = true
end

-- Update list when history changes
awesome.connect_signal("notification_history::updated", function()
    if panel_visible then
        update_notification_list()
    end
end)

-- Hide on global dismiss signal
awesome.connect_signal("elemental::dismiss", function()
    hide()
end)

-- Hide when clicking outside
notification_history_popup:connect_signal("button::press", function(_, _, _, button)
    if button == 1 then
        hide()
    end
end)

-- Make functions globally accessible
notification_history_toggle = toggle
notification_history_hide = hide
notification_history_show = show

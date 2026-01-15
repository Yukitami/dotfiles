local awful = require("awful")
local gears = require("gears")
local wibox = require("wibox")
local beautiful = require("beautiful")
local naughty = require("naughty")
local helpers = require("helpers")

-- Configuration
local max_notifications = 10
local notification_history = {}

-- Icon mapping (same as in notifications/themes/amarena.lua)
local default_icon = ""
local app_icons = {
    ['battery'] = "",
    ['charger'] = "",
    ['volume'] = "",
    ['brightness'] = "",
    ['screenshot'] = "",
    ['Telegram Desktop'] = "",
    ['night_mode'] = "",
    ['NetworkManager'] = "",
    ['youtube'] = "",
    ['mpd'] = "",
    ['mpv'] = "",
    ['keyboard'] = "",
    ['email'] = "",
}

-- Function to get relative time string
local function get_relative_time(timestamp)
    local diff = os.time() - timestamp
    if diff < 60 then
        return "Just now"
    elseif diff < 3600 then
        local mins = math.floor(diff / 60)
        return mins .. "m ago"
    elseif diff < 86400 then
        local hours = math.floor(diff / 3600)
        return hours .. "h ago"
    else
        local days = math.floor(diff / 86400)
        return days .. "d ago"
    end
end

-- Function to create a single notification entry widget
local function create_notification_entry(notif_data)
    local icon = app_icons[notif_data.app_name] or default_icon

    local icon_widget = wibox.widget {
        markup = helpers.colorize_text(icon, x.color4),
        font = "icomoon 12",
        align = "center",
        valign = "center",
        forced_width = dpi(30),
        widget = wibox.widget.textbox
    }

    local title_widget = wibox.widget {
        markup = "<b>" .. helpers.pango_escape(notif_data.title or notif_data.app_name or "Notification") .. "</b>",
        font = "sans medium 9",
        align = "left",
        valign = "center",
        widget = wibox.widget.textbox
    }

    local time_widget = wibox.widget {
        markup = helpers.colorize_text(get_relative_time(notif_data.timestamp), x.color8),
        font = "sans 8",
        align = "right",
        valign = "center",
        widget = wibox.widget.textbox
    }

    local message_widget = wibox.widget {
        markup = helpers.colorize_text(helpers.pango_escape(notif_data.message or ""), x.color8),
        font = "sans 8",
        align = "left",
        valign = "center",
        forced_height = dpi(16),
        widget = wibox.widget.textbox
    }

    local entry = wibox.widget {
        {
            {
                icon_widget,
                {
                    {
                        title_widget,
                        nil,
                        time_widget,
                        layout = wibox.layout.align.horizontal
                    },
                    message_widget,
                    spacing = dpi(2),
                    layout = wibox.layout.fixed.vertical
                },
                spacing = dpi(8),
                layout = wibox.layout.fixed.horizontal
            },
            margins = dpi(8),
            widget = wibox.container.margin
        },
        bg = x.color0 .. "80",
        shape = helpers.rrect(dpi(4)),
        widget = wibox.container.background
    }

    return entry
end

-- The main notification list container
local notification_list = wibox.widget {
    spacing = dpi(6),
    layout = wibox.layout.fixed.vertical
}

-- Empty state widget
local empty_widget = wibox.widget {
    {
        markup = helpers.colorize_text("No notifications", x.color8),
        font = "sans italic 9",
        align = "center",
        valign = "center",
        widget = wibox.widget.textbox
    },
    margins = dpi(10),
    widget = wibox.container.margin
}

-- Header widget
local header_text = wibox.widget {
    markup = helpers.colorize_text("Notifications", x.color7),
    font = "sans bold 10",
    align = "left",
    valign = "center",
    widget = wibox.widget.textbox
}

local clear_button = wibox.widget {
    markup = helpers.colorize_text("", x.color8),
    font = "icomoon 10",
    align = "center",
    valign = "center",
    widget = wibox.widget.textbox
}

clear_button:buttons(gears.table.join(
    awful.button({ }, 1, function()
        notification_history = {}
        notification_list:reset()
        notification_list:add(empty_widget)
    end)
))

helpers.add_hover_cursor(clear_button, "hand1")

clear_button:connect_signal("mouse::enter", function()
    clear_button.markup = helpers.colorize_text("", x.color1)
end)

clear_button:connect_signal("mouse::leave", function()
    clear_button.markup = helpers.colorize_text("", x.color8)
end)

local header = wibox.widget {
    header_text,
    nil,
    clear_button,
    layout = wibox.layout.align.horizontal
}

-- Function to update the notification list display
local function update_notification_list()
    notification_list:reset()

    if #notification_history == 0 then
        notification_list:add(empty_widget)
        return
    end

    -- Show notifications in reverse order (newest first)
    for i = #notification_history, 1, -1 do
        local entry = create_notification_entry(notification_history[i])
        notification_list:add(entry)
    end
end

-- Function to add a notification to history
local function add_notification(n)
    -- Don't add certain transient notifications
    if n.app_name == "volume" or n.app_name == "brightness" then
        return
    end

    local notif_data = {
        app_name = n.app_name or "Unknown",
        title = n.title or "",
        message = n.message or "",
        timestamp = os.time(),
        urgency = n.urgency or "normal"
    }

    table.insert(notification_history, notif_data)

    -- Keep only the last max_notifications
    while #notification_history > max_notifications do
        table.remove(notification_history, 1)
    end

    update_notification_list()
end

-- Connect to naughty to capture notifications
naughty.connect_signal("added", function(n)
    add_notification(n)
end)

-- Timer to update relative timestamps periodically
local update_timer = gears.timer {
    timeout = 60,
    autostart = true,
    callback = function()
        update_notification_list()
    end
}

-- Initialize with empty state
notification_list:add(empty_widget)

-- The main widget to export
local notification_history_widget = wibox.widget {
    {
        header,
        helpers.vertical_pad(dpi(8)),
        notification_list,
        layout = wibox.layout.fixed.vertical
    },
    left = dpi(5),
    right = dpi(5),
    widget = wibox.container.margin
}

return notification_history_widget

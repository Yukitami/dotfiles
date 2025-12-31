local naughty = require("naughty")
local gears = require("gears")

local history = {}

-- Configuration
local MAX_NOTIFICATIONS = 50  -- Maximum number of notifications to keep in history

-- Storage
history.notifications = {}
history.signals = {}

-- Add a notification to history
local function add_to_history(n)
    -- Skip if notification is marked as transient (not to be stored)
    if n.transient then return end

    -- Create a snapshot of the notification data
    local notification_data = {
        title = n.title or "",
        message = n.message or "",
        icon = n.icon,
        app_name = n.app_name or "notification",
        urgency = n.urgency or "normal",
        timestamp = os.time(),
        timeout = n.timeout,
    }

    -- Add to the beginning of the list (newest first)
    table.insert(history.notifications, 1, notification_data)

    -- Limit the history size
    if #history.notifications > MAX_NOTIFICATIONS then
        table.remove(history.notifications)
    end

    -- Emit signal for UI updates
    awesome.emit_signal("notification_history::updated")
end

-- Clear all history
function history.clear()
    history.notifications = {}
    awesome.emit_signal("notification_history::updated")
end

-- Remove a specific notification by index
function history.remove(index)
    if history.notifications[index] then
        table.remove(history.notifications, index)
        awesome.emit_signal("notification_history::updated")
    end
end

-- Get formatted time string
function history.get_time_string(timestamp)
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

-- Initialize the history module
function history.init()
    -- Connect to the notification display signal
    naughty.connect_signal("request::display", function(n)
        -- Add notification to history
        add_to_history(n)
    end)
end

return history

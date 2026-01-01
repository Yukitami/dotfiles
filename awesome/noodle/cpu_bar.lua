local awful = require("awful")
local gears = require("gears")
local wibox = require("wibox")
local beautiful = require("beautiful")
local modern_ui = require("modern_ui")

-- Modern color scheme
local active_color = beautiful.cpu_bar_active_color or "#5AA3CC"
local background_color = x.color8 .. "30"

local cpu_bar = wibox.widget{
    max_value     = 100,
    value         = 50,
    forced_height = dpi(10),
    margins       = {
        top = modern_ui.spacing.sm,
        bottom = modern_ui.spacing.sm,
    },
    forced_width  = dpi(200),
    shape         = gears.shape.rounded_bar,
    bar_shape     = gears.shape.rounded_bar,
    color         = active_color,
    background_color = background_color,
    border_width  = 0,
    border_color  = beautiful.border_color,
    widget        = wibox.widget.progressbar,
}

awesome.connect_signal("evil::cpu", function(value)
    -- Use this if you want to display usage percentage
    -- cpu_bar.value = value
    -- Use this if you want to display idle percentage
    cpu_bar.value = tonumber(100 - value)
end)

return cpu_bar

local gears = require("gears")
local wibox = require("wibox")
local beautiful = require("beautiful")
local modern_ui = require("modern_ui")

-- Modern color scheme
local active_color = beautiful.ram_bar_active_color or "#5AA3CC"
local background_color = x.color8 .. "30"

local ram_bar = wibox.widget{
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

awesome.connect_signal("evil::ram", function(used, total)
    local used_ram_percentage = (used / total) * 100
    ram_bar.value = used_ram_percentage
end)

return ram_bar

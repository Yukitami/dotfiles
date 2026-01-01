local gears = require("gears")
local wibox = require("wibox")
local beautiful = require("beautiful")
local modern_ui = require("modern_ui")

-- Modern color scheme
local active_color = beautiful.volume_bar_active_color or "#5AA3CC"
local muted_color = beautiful.volume_bar_muted_color or "#666666"
local active_background_color = x.color8 .. "30"
local muted_background_color = x.color8 .. "20"

local volume_bar = wibox.widget{
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
    background_color = active_background_color,
    border_width  = 0,
    border_color  = beautiful.border_color,
    widget        = wibox.widget.progressbar,
}

awesome.connect_signal("evil::volume", function(volume, muted)
    local bg_color
    if muted then
        fill_color = muted_color
        bg_color = muted_background_color
    else
        fill_color = active_color
        bg_color = active_background_color
    end
    volume_bar.value = volume
    volume_bar.color = fill_color
    volume_bar.background_color = bg_color
end)

return volume_bar

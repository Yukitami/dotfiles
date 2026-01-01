local awful = require("awful")
local gears = require("gears")
local wibox = require("wibox")
local beautiful = require("beautiful")
local apps = require("apps")

local helpers = require("helpers")
local modern_ui = require("modern_ui")

-- Helper function that changes the appearance of progress bars and their icons
local function format_progress_bar(bar)
    -- Since we will rotate the bars 90 degrees, width and height are reversed
    bar.forced_width = dpi(70)
    bar.forced_height = dpi(30)
    bar.shape = helpers.rrect(modern_ui.radius.full)
    bar.bar_shape = gears.shape.rectangle
    local w = wibox.widget{
        bar,
        direction = 'east',
        layout = wibox.container.rotate,
    }
    return w
end

-- Item configuration
-- ==================
-- Weather widget with text icons
local weather_widget = require("noodle.text_weather")
local weather_widget_icon = weather_widget:get_all_children()[1]
weather_widget_icon.font = modern_ui.typography.icon_lg.font
weather_widget_icon.align = "center"
weather_widget_icon.valign = "center"
local weather_widget_description = weather_widget:get_all_children()[2]
weather_widget_description.font = modern_ui.typography.body_lg.font
local weather_widget_temperature = weather_widget:get_all_children()[3]
weather_widget_temperature.font = modern_ui.typography.heading_lg.font

-- Modern weather card
local weather = modern_ui.create_card({
    content = wibox.widget{
        {
            nil,
            weather_widget_description,
            expand = "none",
            layout = wibox.layout.align.horizontal
        },
        {
            nil,
            {
                weather_widget_icon,
                weather_widget_temperature,
                spacing = modern_ui.spacing.sm,
                layout = wibox.layout.fixed.horizontal
            },
            expand = "none",
            layout = wibox.layout.align.horizontal
        },
        spacing = modern_ui.spacing.xs,
        layout = wibox.layout.fixed.vertical
    },
    padding = modern_ui.spacing.md,
    bg_color = modern_ui.colors.surface_0,
    radius = modern_ui.radius.lg,
    border = modern_ui.elevation.low,
})

local temperature_bar = require("noodle.temperature_bar")
local temperature = format_progress_bar(temperature_bar)
temperature:buttons(
    gears.table.join(
        awful.button({ }, 1, apps.temperature_monitor)
))

local cpu_bar = require("noodle.cpu_bar")
local cpu = format_progress_bar(cpu_bar)

cpu:buttons(
    gears.table.join(
        awful.button({ }, 1, apps.process_monitor),
        awful.button({ }, 3, apps.process_monitor_gui)
))

local ram_bar = require("noodle.ram_bar")
local ram = format_progress_bar(ram_bar)

ram:buttons(
    gears.table.join(
        awful.button({ }, 1, apps.process_monitor),
        awful.button({ }, 3, apps.process_monitor_gui)
))


local brightness_bar = require("noodle.brightness_bar")
local brightness = format_progress_bar(brightness_bar)

brightness:buttons(
    gears.table.join(
        -- Left click - Toggle redshift
        awful.button({ }, 1, apps.night_mode),
        -- Right click - Reset brightness (Set to max)
        awful.button({ }, 3, function ()
            awful.spawn.with_shell("light -S 100")
        end),
        -- Scroll up - Increase brightness
        awful.button({ }, 4, function ()
            awful.spawn.with_shell("light -A 10")
        end),
        -- Scroll down - Decrease brightness
        awful.button({ }, 5, function ()
            awful.spawn.with_shell("light -U 10")
        end)
))

local hours = wibox.widget.textclock("%H")
local minutes = wibox.widget.textclock("%M")

local make_little_dot = function (color)
    return wibox.widget{
        bg = color,
        forced_width = dpi(10),
        forced_height = dpi(10),
        shape = helpers.rrect(modern_ui.radius.sm),
        widget = wibox.container.background
    }
end

-- Modern time display
local time = {
    {
        font = "biotif extra bold 44",
        align = "right",
        valign = "top",
        widget = hours
    },
    {
        nil,
        {
            make_little_dot(x.color1),
            make_little_dot(x.color4),
            make_little_dot(x.color5),
            spacing = modern_ui.spacing.md,
            widget = wibox.layout.fixed.vertical
        },
        expand = "none",
        widget = wibox.layout.align.vertical
    },
    {
        font = "biotif extra bold 44",
        align = "left",
        valign = "top",
        widget = minutes
    },
    spacing = modern_ui.spacing.xl,
    layout = wibox.layout.fixed.horizontal
}

-- Day of the week (dotw)
local dotw = require("noodle.day_of_the_week")
local day_of_the_week = wibox.widget {
    nil,
    dotw,
    expand = "none",
    layout = wibox.layout.align.horizontal
}

-- Mpd
local mpd_buttons = require("noodle.mpd_buttons")
local mpd_song = require("noodle.mpd_song")
local mpd_widget_children = mpd_song:get_all_children()
local mpd_title = mpd_widget_children[1]
local mpd_artist = mpd_widget_children[2]
mpd_title.font = modern_ui.typography.heading_md.font
mpd_artist.font = modern_ui.typography.body_md.font

-- Set forced height in order to limit the widgets to one line.
-- Might need to be adjusted depending on the font.
mpd_title.forced_height = dpi(22)
mpd_artist.forced_height = dpi(16)

mpd_song:buttons(gears.table.join(
    awful.button({ }, 1, function ()
        awful.spawn.with_shell("mpc -q toggle")
    end),
    awful.button({ }, 3, apps.music),
    awful.button({ }, 4, function ()
        awful.spawn.with_shell("mpc -q prev")
    end),
    awful.button({ }, 5, function ()
        awful.spawn.with_shell("mpc -q next")
    end)
))

-- Modern MPD card
local mpd_card = modern_ui.create_card({
    content = wibox.widget{
        mpd_buttons,
        mpd_song,
        spacing = modern_ui.spacing.sm,
        layout = wibox.layout.fixed.vertical
    },
    padding = modern_ui.spacing.lg,
    bg_color = modern_ui.colors.surface_0,
    radius = modern_ui.radius.lg,
    border = modern_ui.elevation.low,
})

local search_icon = wibox.widget {
    font = modern_ui.typography.icon_sm.font,
    align = "center",
    valign = "center",
    widget = wibox.widget.textbox()
}

local reset_search_icon = function ()
    search_icon.markup = helpers.colorize_text("", modern_ui.colors.accent_primary)
end
reset_search_icon()

local search_text = wibox.widget {
    align = "center",
    valign = "center",
    font = modern_ui.typography.body_md.font,
    widget = wibox.widget.textbox()
}

-- Modern search bar
local search = wibox.widget{
    {
        {
            search_icon,
            {
                search_text,
                bottom = dpi(2),
                widget = wibox.container.margin
            },
            spacing = modern_ui.spacing.sm,
            layout = wibox.layout.fixed.horizontal
        },
        left = modern_ui.spacing.lg,
        widget = wibox.container.margin
    },
    forced_height = dpi(40),
    forced_width = dpi(200),
    shape = helpers.rrect(modern_ui.radius.full),
    bg = modern_ui.colors.surface_0,
    border_width = dpi(1),
    border_color = x.color8 .. "30",
    widget = wibox.container.background()
}

-- Modern search bar hover effect
search:connect_signal("mouse::enter", function()
    search.border_color = modern_ui.colors.accent_primary .. "60"
end)

search:connect_signal("mouse::leave", function()
    search.border_color = x.color8 .. "30"
end)

local function generate_prompt_icon(icon, color)
    return "<span font='" .. modern_ui.typography.icon_sm.font .. "' foreground='" .. color .."'>" .. icon .. "</span> "
end

function sidebar_activate_prompt(action)
    sidebar.visible = true
    search_icon.visible = false
    local prompt
    if action == "run" then
        prompt = generate_prompt_icon("", modern_ui.colors.accent_success)
    elseif action == "web_search" then
        prompt = generate_prompt_icon("", modern_ui.colors.accent_primary)
    end
    helpers.prompt(action, search_text, prompt, function()
        search_icon.visible = true
        if mouse.current_wibox ~= sidebar then
            sidebar.visible = false
        end
    end)
end

local prompt_is_active = function ()
    -- The search icon is hidden and replaced by other icons
    -- when the prompt is running
    return not search_icon.visible
end

search:buttons(gears.table.join(
    awful.button({ }, 1, function ()
        sidebar_activate_prompt("run")
    end),
    awful.button({ }, 3, function ()
        sidebar_activate_prompt("web_search")
    end)
))

local volume_bar = require("noodle.volume_bar")
local volume = format_progress_bar(volume_bar)

-- Notification history widget
local notification_history_widget = require("elemental.notification_history")

volume:buttons(gears.table.join(
    -- Left click - Mute / Unmute
    awful.button({ }, 1, function ()
        helpers.volume_control(0)
    end),
    -- Right click - Run or raise pavucontrol
    awful.button({ }, 3, apps.volume),
    -- Scroll - Increase / Decrease volume
    awful.button({ }, 4, function ()
        helpers.volume_control(2)
    end),
    awful.button({ }, 5, function ()
        helpers.volume_control(-2)
    end)
))

-- Battery
local cute_battery_face = require("noodle.cute_battery_face")
cute_battery_face:buttons(gears.table.join(
    awful.button({ }, 1, apps.battery_monitor)
))

-- Create tooltip widget
-- It should change depending on what the user is hovering over
local adaptive_tooltip = wibox.widget {
    visible = false,
    top_only = true,
    layout = wibox.layout.stack
}

-- Modern tooltip styling
local function create_tooltip(w)
    local tooltip = wibox.widget {
        font = modern_ui.typography.body_md.font,
        align = "center",
        valign = "center",
        widget = wibox.widget.textbox
    }

    tooltip_counter = tooltip_counter or 0
    tooltip_counter = tooltip_counter + 1
    local index = tooltip_counter

    adaptive_tooltip:insert(index, tooltip)

    w:connect_signal("mouse::enter", function()
        -- Raise tooltip to the top of the stack
        adaptive_tooltip:set(1, tooltip)
        adaptive_tooltip.visible = true
    end)
    w:connect_signal("mouse::leave", function ()
        adaptive_tooltip.visible = false
    end)

    return tooltip
end

local brightness_tooltip = create_tooltip(brightness_bar)
awesome.connect_signal("evil::brightness", function(value)
    brightness_tooltip.markup = "<span foreground='" .. modern_ui.colors.text_secondary .. "'>Your screen is </span><span foreground='" .. beautiful.brightness_bar_active_color .."'><b>" .. tostring(value) .. "%</b></span><span foreground='" .. modern_ui.colors.text_secondary .. "'> bright</span>"
end)

local cpu_tooltip = create_tooltip(cpu_bar)
awesome.connect_signal("evil::cpu", function(value)
    cpu_tooltip.markup = "<span foreground='" .. modern_ui.colors.text_secondary .. "'>You are using </span><span foreground='" .. beautiful.cpu_bar_active_color .."'><b>" .. tostring(value) .. "%</b></span><span foreground='" .. modern_ui.colors.text_secondary .. "'> of CPU</span>"
end)

local ram_tooltip = create_tooltip(ram_bar)
awesome.connect_signal("evil::ram", function(value, _)
    ram_tooltip.markup = "<span foreground='" .. modern_ui.colors.text_secondary .. "'>You are using </span><span foreground='" .. beautiful.ram_bar_active_color .."'><b>" .. string.format("%.1f", value / 1000) .. "G</b></span><span foreground='" .. modern_ui.colors.text_secondary .. "'> of memory</span>"
end)

local volume_tooltip = create_tooltip(volume_bar)
awesome.connect_signal("evil::volume", function(value, muted)
    volume_tooltip.markup = "<span foreground='" .. modern_ui.colors.text_secondary .. "'>The volume is at </span><span foreground='" .. beautiful.volume_bar_active_color .."'><b>" .. tostring(value) .. "%</b></span>"
    if muted then
        volume_tooltip.markup = volume_tooltip.markup.."<span foreground='" .. modern_ui.colors.text_secondary .. "'> and </span><span foreground='" .. beautiful.volume_bar_active_color .."'><b>muted</b></span>"
    end
end)

local temperature_tooltip = create_tooltip(temperature_bar)
awesome.connect_signal("evil::temperature", function(value)
    temperature_tooltip.markup = "<span foreground='" .. modern_ui.colors.text_secondary .. "'>Your CPU temperature is at </span><span foreground='" .. beautiful.temperature_bar_active_color .."'><b>" .. tostring(value) .. "°C</b></span>"
end)

local battery_tooltip = create_tooltip(cute_battery_face)
awesome.connect_signal("evil::battery", function(value)
    battery_tooltip.markup = "<span foreground='" .. modern_ui.colors.text_secondary .. "'>Your battery is at </span><span foreground='" .. beautiful.battery_bar_active_color .."'><b>" .. tostring(value) .. "%</b></span>"
end)

-- Add clickable mouse effects on some widgets
helpers.add_hover_cursor(cpu, "hand1")
helpers.add_hover_cursor(ram, "hand1")
helpers.add_hover_cursor(temperature, "hand1")
helpers.add_hover_cursor(volume, "hand1")
helpers.add_hover_cursor(brightness, "hand1")
helpers.add_hover_cursor(mpd_song, "hand1")
helpers.add_hover_cursor(search, "xterm")
helpers.add_hover_cursor(cute_battery_face, "hand1")


-- Create the sidebar
sidebar = wibox({visible = false, ontop = true, type = "dock", screen = screen.primary})
sidebar.bg = "#00000000" -- For anti aliasing
sidebar.fg = beautiful.sidebar_fg or beautiful.wibar_fg or "#FFFFFF"
sidebar.opacity = beautiful.sidebar_opacity or 1
sidebar.height = screen.primary.geometry.height
sidebar.width = beautiful.sidebar_width or dpi(300)
sidebar.y = beautiful.sidebar_y or 0
local radius = beautiful.sidebar_border_radius or 0
if beautiful.sidebar_position == "right" then
    awful.placement.top_right(sidebar)
else
    awful.placement.top_left(sidebar)
end
awful.placement.maximize_vertically(sidebar, { honor_workarea = true, margins = { top = beautiful.useless_gap * 2 } })

sidebar:buttons(gears.table.join(
    -- Middle click - Hide sidebar
    awful.button({ }, 2, function ()
        sidebar_hide()
    end)
))

sidebar_show = function()
    sidebar.visible = true
end

sidebar_hide = function()
    -- Do not hide it if prompt is active
    if not prompt_is_active() then
        sidebar.visible = false
    end
end

sidebar_toggle = function()
    if sidebar.visible then
        sidebar_hide()
    else
        sidebar.visible = true
    end
end

-- Hide sidebar when mouse leaves
if user.sidebar.hide_on_mouse_leave then
    sidebar:connect_signal("mouse::leave", function ()
        sidebar_hide()
    end)
end
-- Activate sidebar by moving the mouse at the edge of the screen
if user.sidebar.show_on_mouse_screen_edge then
    local sidebar_activator = wibox({y = sidebar.y, width = 1, visible = true, ontop = false, opacity = 0, below = true, screen = screen.primary})
    sidebar_activator.height = sidebar.height
    sidebar_activator:connect_signal("mouse::enter", function ()
        sidebar.visible = true
    end)

    if beautiful.sidebar_position == "right" then
        awful.placement.right(sidebar_activator)
    else
        awful.placement.left(sidebar_activator)
    end

    sidebar_activator:buttons(
        gears.table.join(
            awful.button({ }, 4, function ()
                awful.tag.viewprev()
            end),
            awful.button({ }, 5, function ()
                awful.tag.viewnext()
            end)
    ))
end


-- Item placement with modern spacing
sidebar:setup {
    {
        { ----------- TOP GROUP -----------
            {
                helpers.vertical_pad(modern_ui.spacing.xxxl),
                {
                    nil,
                    {
                        time,
                        spacing = modern_ui.spacing.md,
                        layout = wibox.layout.fixed.horizontal
                    },
                    expand = "none",
                    layout = wibox.layout.align.horizontal
                },
                helpers.vertical_pad(modern_ui.spacing.xl),
                day_of_the_week,
                helpers.vertical_pad(modern_ui.spacing.xxl),
                {
                    nil,
                    cute_battery_face,
                    expand = "none",
                    layout = wibox.layout.align.horizontal,
                },
                helpers.vertical_pad(modern_ui.spacing.xxxl),
                layout = wibox.layout.fixed.vertical
            },
            layout = wibox.layout.fixed.vertical
        },
        { ----------- MIDDLE GROUP -----------
            {
                helpers.vertical_pad(modern_ui.spacing.xxxl),
                {
                    weather,
                    left = modern_ui.spacing.xl,
                    right = modern_ui.spacing.xl,
                    widget = wibox.container.margin
                },
                helpers.vertical_pad(modern_ui.spacing.xl),
                {
                    mpd_card,
                    left = modern_ui.spacing.xl,
                    right = modern_ui.spacing.xl,
                    widget = wibox.container.margin
                },
                helpers.vertical_pad(modern_ui.spacing.xxl),
                {
                    nil,
                    {
                        volume,
                        cpu,
                        temperature,
                        ram,
                        brightness,
                        spacing = modern_ui.spacing.sm,
                        layout = wibox.layout.fixed.horizontal
                    },
                    expand = "none",
                    layout = wibox.layout.align.horizontal
                },
                helpers.vertical_pad(modern_ui.spacing.lg),
                -- Notification history
                {
                    notification_history_widget,
                    left = modern_ui.spacing.xl,
                    right = modern_ui.spacing.xl,
                    widget = wibox.container.margin
                },
                helpers.vertical_pad(modern_ui.spacing.lg),
                layout = wibox.layout.fixed.vertical
            },
            shape = helpers.prrect(beautiful.sidebar_border_radius, false, true, false, false),
            bg = x.color0.."66",
            widget = wibox.container.background
        },
        { ----------- BOTTOM GROUP -----------
            {
                {
                    {
                        nil,
                        adaptive_tooltip,
                        expand = "none",
                        layout = wibox.layout.align.horizontal,
                    },
                    helpers.vertical_pad(modern_ui.spacing.xxxl),
                    {
                        nil,
                        search,
                        expand = "none",
                        layout = wibox.layout.align.horizontal,
                    },
                    layout = wibox.layout.fixed.vertical
                },
                left = modern_ui.spacing.xl,
                right = modern_ui.spacing.xl,
                bottom = modern_ui.spacing.xxxl,
                widget = wibox.container.margin
            },
            bg = x.color0.."66",
            widget = wibox.container.background
        },
        layout = wibox.layout.align.vertical,
    },
    shape = helpers.prrect(beautiful.sidebar_border_radius, false, true, false, false),
    bg = beautiful.sidebar_bg or beautiful.wibar_bg or "#111111",
    widget = wibox.container.background
}

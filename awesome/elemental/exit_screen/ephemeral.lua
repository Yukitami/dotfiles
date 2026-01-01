local awful = require("awful")
local gears = require("gears")
local wibox = require("wibox")
local beautiful = require("beautiful")

local helpers = require("helpers")
local modern_ui = require("modern_ui")

-- Modern appearance with design tokens
local icon_font = modern_ui.typography.icon_xxl.font
local poweroff_text_icon = ""
local reboot_text_icon = ""
local suspend_text_icon = ""
local exit_text_icon = ""
local lock_text_icon = ""

-- Commands
local poweroff_command = function()
    awful.spawn.with_shell("poweroff")
end
local reboot_command = function()
    awful.spawn.with_shell("reboot")
end
local suspend_command = function()
    lock_screen_show()
    awful.spawn.with_shell("systemctl suspend")
end
local exit_command = function()
    awesome.quit()
end
local lock_command = function()
    lock_screen_show()
end

-- Modern button factory using design system
local create_modern_button = function(icon, color, command)
    local button_size = dpi(120)

    local icon_widget = wibox.widget {
        markup = helpers.colorize_text(icon, modern_ui.colors.text_primary),
        font = icon_font,
        align = "center",
        valign = "center",
        widget = wibox.widget.textbox()
    }

    local button = wibox.widget {
        {
            nil,
            icon_widget,
            expand = "none",
            layout = wibox.layout.align.horizontal
        },
        forced_height = button_size,
        forced_width = button_size,
        border_width = dpi(3),
        border_color = x.color8 .. "30",
        shape = helpers.rrect(modern_ui.radius.xl),
        bg = modern_ui.colors.surface_0,
        widget = wibox.container.background
    }

    -- Bind left click to run the command
    button:buttons(gears.table.join(
        awful.button({ }, 1, function ()
            command()
        end)
    ))

    -- Modern hover effects
    button:connect_signal("mouse::enter", function ()
        icon_widget.markup = helpers.colorize_text(icon, color)
        button.border_color = color .. "80"
        button.bg = color .. "15"
    end)
    button:connect_signal("mouse::leave", function ()
        icon_widget.markup = helpers.colorize_text(icon, modern_ui.colors.text_primary)
        button.border_color = x.color8 .. "30"
        button.bg = modern_ui.colors.surface_0
    end)

    helpers.add_hover_cursor(button, "hand1")

    return button
end

-- Create modern buttons with color coding
local poweroff = create_modern_button(poweroff_text_icon, modern_ui.colors.accent_error, poweroff_command)
local reboot = create_modern_button(reboot_text_icon, modern_ui.colors.accent_warning, reboot_command)
local suspend = create_modern_button(suspend_text_icon, modern_ui.colors.accent_info, suspend_command)
local exit = create_modern_button(exit_text_icon, modern_ui.colors.accent_primary, exit_command)
local lock = create_modern_button(lock_text_icon, modern_ui.colors.accent_secondary, lock_command)

-- Create the exit screen wibox
exit_screen = wibox({visible = false, ontop = true, type = "dock"})
awful.placement.maximize(exit_screen)

exit_screen.bg = beautiful.exit_screen_bg or beautiful.wibar_bg or "#111111"
exit_screen.fg = beautiful.exit_screen_fg or beautiful.wibar_fg or "#FEFEFE"

local exit_screen_grabber
function exit_screen_hide()
    awful.keygrabber.stop(exit_screen_grabber)
    exit_screen.visible = false
end

local keybinds = {
    ['escape'] = exit_screen_hide,
    ['q'] = exit_screen_hide,
    ['x'] = exit_screen_hide,
    ['s'] = function () suspend_command(); exit_screen_hide() end,
    ['e'] = exit_command,
    ['p'] = poweroff_command,
    ['r'] = reboot_command,
    ['l'] = function ()
        lock_command()
        -- Kinda fixes the "white" (undimmed) flash that appears between
        -- exit screen disappearing and lock screen appearing
        gears.timer.delayed_call(function()
            exit_screen_hide()
        end)
    end
}

function exit_screen_show()
    exit_screen_grabber = awful.keygrabber.run(function(_, key, event)
        -- Ignore case
        key = key:lower()

        if event == "release" then return end

        if keybinds[key] then
            keybinds[key]()
        end
    end)
    exit_screen.visible = true
end

exit_screen:buttons(gears.table.join(
    -- Left click - Hide exit_screen
    awful.button({ }, 1, function ()
        exit_screen_hide()
    end),
    -- Middle click - Hide exit_screen
    awful.button({ }, 2, function ()
        exit_screen_hide()
    end),
    -- Right click - Hide exit_screen
    awful.button({ }, 3, function ()
        exit_screen_hide()
    end)
))

-- Modern item placement with better spacing
exit_screen:setup {
    nil,
    {
        nil,
        {
            poweroff,
            reboot,
            suspend,
            exit,
            lock,
            spacing = modern_ui.spacing.xxxl,
            layout = wibox.layout.fixed.horizontal
        },
        expand = "none",
        layout = wibox.layout.align.horizontal
    },
    expand = "none",
    layout = wibox.layout.align.vertical
}

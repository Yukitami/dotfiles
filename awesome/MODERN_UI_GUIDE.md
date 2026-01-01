# Modern UI Design System Guide

This guide shows how to use the modern design system (`modern_ui.lua`) to update your AwesomeWM configuration with contemporary UX/UI trends.

## Overview

The modern design system provides:
- **Consistent spacing, typography, and colors**
- **Reusable UI components** (cards, buttons, badges, avatars)
- **Modern visual style** (rounded corners, subtle borders, hover effects)
- **Accessibility** (clear hierarchy, proper contrast)

## Quick Start

```lua
local modern_ui = require("modern_ui")

-- Create a modern card
local my_card = modern_ui.create_card({
    content = my_widget,
    padding = modern_ui.spacing.lg,
    radius = modern_ui.radius.lg,
})

-- Create a modern button
local my_button = modern_ui.create_button({
    icon = "",
    text = "Settings",
    style = "primary",
    size = "md",
    on_click = function() awful.spawn("settings") end
})
```

## Design Tokens

### Spacing Scale

```lua
modern_ui.spacing.xs     -- 4px
modern_ui.spacing.sm     -- 8px
modern_ui.spacing.md     -- 12px (recommended default)
modern_ui.spacing.lg     -- 16px
modern_ui.spacing.xl     -- 20px
modern_ui.spacing.xxl    -- 24px
modern_ui.spacing.xxxl   -- 32px
```

**Usage**: Use consistent spacing throughout your UI. Default to `md` for most padding/margins.

### Border Radius

```lua
modern_ui.radius.sm      -- 4px (subtle rounding)
modern_ui.radius.md      -- 8px (moderate rounding)
modern_ui.radius.lg      -- 12px (recommended default)
modern_ui.radius.xl      -- 16px (pronounced rounding)
modern_ui.radius.full    -- 9999px (circular)
```

**Usage**: Use `lg` for cards/panels, `full` for circular buttons/avatars.

### Elevation (Borders for Depth)

```lua
modern_ui.elevation.none     -- No border
modern_ui.elevation.low      -- 1px subtle border (recommended default)
modern_ui.elevation.medium   -- 1px medium border
modern_ui.elevation.high     -- 2px strong border
```

**Usage**: Apply to cards for subtle depth without heavy shadows.

### Typography

```lua
-- Display (large headers)
modern_ui.typography.display_lg.font   -- "sans extra bold 28"
modern_ui.typography.display_md.font   -- "sans extra bold 24"
modern_ui.typography.display_sm.font   -- "sans bold 20"

-- Headings
modern_ui.typography.heading_lg.font   -- "sans bold 16"
modern_ui.typography.heading_md.font   -- "sans bold 12"
modern_ui.typography.heading_sm.font   -- "sans bold 10"

-- Body text
modern_ui.typography.body_lg.font      -- "sans 11"
modern_ui.typography.body_md.font      -- "sans 9"
modern_ui.typography.body_sm.font      -- "sans 8"

-- Icons
modern_ui.typography.icon_xl.font      -- "icomoon 24"
modern_ui.typography.icon_lg.font      -- "icomoon 18"
modern_ui.typography.icon_md.font      -- "icomoon 14"
```

**Usage**: Use heading fonts for titles, body for content, maintain hierarchy.

### Colors

```lua
-- Surfaces
modern_ui.colors.surface_0    -- Base surface (x.color0)
modern_ui.colors.surface_1    -- Slightly transparent
modern_ui.colors.surface_2    -- More transparent

-- Text
modern_ui.colors.text_primary    -- Main text (x.foreground)
modern_ui.colors.text_secondary  -- Secondary text (x.color7)
modern_ui.colors.text_tertiary   -- Tertiary/muted (x.color8)

-- Accents
modern_ui.colors.accent_primary    -- Blue (x.color4)
modern_ui.colors.accent_success    -- Green (x.color2)
modern_ui.colors.accent_warning    -- Yellow (x.color3)
modern_ui.colors.accent_error      -- Red (x.color1)
```

## Components

### Cards

Create modern card layouts with consistent styling:

```lua
local modern_ui = require("modern_ui")

local my_card = modern_ui.create_card({
    content = your_widget,              -- Required: widget to wrap
    padding = modern_ui.spacing.lg,     -- Optional: inner padding
    bg_color = modern_ui.colors.surface_0,  -- Optional: background
    border = modern_ui.elevation.low,   -- Optional: border style
    radius = modern_ui.radius.lg,       -- Optional: corner radius
    hover_effect = true,                -- Optional: hover animation
    width = dpi(300),                   -- Optional: fixed width
    height = dpi(200),                  -- Optional: fixed height
})
```

**Example - Weather Card**:
```lua
local weather_card = modern_ui.create_card({
    content = wibox.widget {
        {
            markup = helpers.colorize_text("", modern_ui.colors.accent_primary),
            font = modern_ui.typography.icon_xl.font,
            align = "center",
            widget = wibox.widget.textbox,
        },
        {
            markup = "<span foreground='" .. modern_ui.colors.text_primary .. "'>23°C</span>",
            font = modern_ui.typography.display_sm.font,
            align = "center",
            widget = wibox.widget.textbox,
        },
        {
            markup = "<span foreground='" .. modern_ui.colors.text_secondary .. "'>Clear Sky</span>",
            font = modern_ui.typography.body_md.font,
            align = "center",
            widget = wibox.widget.textbox,
        },
        spacing = modern_ui.spacing.sm,
        layout = wibox.layout.fixed.vertical,
    },
    padding = modern_ui.spacing.xl,
    width = dpi(200),
})
```

### Buttons

Create consistent, interactive buttons:

```lua
local my_button = modern_ui.create_button({
    icon = "",                    -- Optional: icon character
    text = "Click Me",                -- Optional: button text
    style = "primary",                -- primary, secondary, ghost, danger
    size = "md",                      -- sm, md, lg
    shape = "rounded",                -- rounded, circular
    on_click = function()
        -- Your click handler
    end
})
```

**Styles**:
- `primary`: Colored background, accent color (for main actions)
- `secondary`: Neutral background (for secondary actions)
- `ghost`: Transparent background (for tertiary actions)
- `danger`: Red-colored (for destructive actions)

**Example - Action Buttons**:
```lua
local buttons_row = wibox.widget {
    modern_ui.create_button({
        icon = "",
        style = "primary",
        size = "lg",
        on_click = function() awesome.quit() end
    }),
    modern_ui.create_button({
        icon = "",
        style = "secondary",
        size = "lg",
        on_click = function() awesome.restart() end
    }),
    modern_ui.create_button({
        icon = "",
        style = "danger",
        size = "lg",
        on_click = function() awful.spawn("poweroff") end
    }),
    spacing = modern_ui.spacing.md,
    layout = wibox.layout.fixed.horizontal,
}
```

### Badges/Chips

Create small labels with icons:

```lua
local my_badge = modern_ui.create_badge({
    text = "New",                    -- Optional: badge text
    icon = "",                      -- Optional: icon
    color = modern_ui.colors.accent_success,  -- Badge color
    size = "sm",                     -- xs, sm, md
})
```

**Example - Status Indicators**:
```lua
local status_badges = wibox.widget {
    modern_ui.create_badge({
        icon = "",
        text = "Online",
        color = modern_ui.colors.accent_success,
    }),
    modern_ui.create_badge({
        icon = "",
        text = "5 notifications",
        color = modern_ui.colors.accent_primary,
    }),
    spacing = modern_ui.spacing.sm,
    layout = wibox.layout.fixed.horizontal,
}
```

### Avatars

Create circular or rounded user avatars:

```lua
local my_avatar = modern_ui.create_avatar({
    image = "/path/to/image.png",   -- For image avatars
    -- OR
    icon = "",                     -- For icon avatars
    -- OR
    text = "UN",                      -- For text avatars (initials)

    size = "md",                      -- sm, md, lg, xl, xxl
    shape = "circular",               -- circular, rounded
})
```

**Example - User Profile**:
```lua
local user_profile = wibox.widget {
    modern_ui.create_avatar({
        image = user.profile_picture,
        size = "xl",
        shape = "circular",
    }),
    {
        markup = "<span foreground='" .. modern_ui.colors.text_primary .. "'><b>John Doe</b></span>",
        font = modern_ui.typography.heading_lg.font,
        align = "center",
        widget = wibox.widget.textbox,
    },
    {
        markup = "<span foreground='" .. modern_ui.colors.text_secondary .. "'>@johndoe</span>",
        font = modern_ui.typography.body_md.font,
        align = "center",
        widget = wibox.widget.textbox,
    },
    spacing = modern_ui.spacing.md,
    layout = wibox.layout.fixed.vertical,
}
```

### Progress Bars

Create modern progress indicators:

```lua
local my_progress = modern_ui.create_progress_bar({
    value = 75,                                    -- Current value
    max_value = 100,                               -- Maximum value
    color = modern_ui.colors.accent_primary,       -- Bar color
    height = dpi(8),                               -- Bar height
    width = dpi(200),                              -- Bar width
    show_text = true,                              -- Show percentage
})
```

### Dividers

Create visual separators:

```lua
local divider = modern_ui.create_divider({
    orientation = "horizontal",  -- horizontal or vertical
    color = x.color8 .. "20",   -- Divider color
    thickness = dpi(1),         -- Thickness
})
```

## Migration Examples

### Before (Old Style)

```lua
local old_widget = wibox.widget {
    {
        my_content,
        margins = dpi(10),
        widget = wibox.container.margin,
    },
    bg = x.color0,
    shape = helpers.rrect(dpi(4)),
    widget = wibox.container.background,
}
```

### After (Modern Style)

```lua
local modern_ui = require("modern_ui")

local new_widget = modern_ui.create_card({
    content = my_content,
    padding = modern_ui.spacing.md,
    radius = modern_ui.radius.lg,
    border = modern_ui.elevation.low,
})
```

## Best Practices

1. **Consistency**: Use the design tokens throughout for consistent spacing and sizing
2. **Hierarchy**: Use typography scale to create clear visual hierarchy
3. **Spacing**: Give elements room to breathe - don't cram content
4. **Feedback**: All interactive elements should have hover states
5. **Colors**: Use accent colors sparingly for emphasis
6. **Simplicity**: Modern design favors simplicity over ornamentation

## Component Modernization Checklist

When updating a component:

- [ ] Replace hardcoded spacing with `modern_ui.spacing.*`
- [ ] Replace hardcoded radii with `modern_ui.radius.*`
- [ ] Use `modern_ui.create_card()` for panel/card layouts
- [ ] Use `modern_ui.create_button()` for buttons
- [ ] Update fonts to use `modern_ui.typography.*`
- [ ] Add hover effects to interactive elements
- [ ] Use `modern_ui.elevation.*` for subtle depth
- [ ] Apply `modern_ui.colors.*` for consistent colors
- [ ] Add proper cursor feedback (`helpers.add_hover_cursor`)
- [ ] Increase padding/margins for better breathing room

## Next Steps

Apply this design system to your components:

1. **Sidebar** - Wrap sections in cards, modernize buttons
2. **Dashboard** - Use card layouts, update typography
3. **Bar/Dock** - Modern button styles, better spacing
4. **Exit Screen** - Card-based layout, modern buttons
5. **Widgets** - Update progress bars, badges, icons

The notification history (`elemental/notification_history.lua`) already uses many of these patterns - use it as a reference!

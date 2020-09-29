--            _ _
--   _____  _(_) |_ ___  ___ _ __ ___  ___ _ __
--  / _ \ \/ / | __/ __|/ __| '__/ _ \/ _ \ '_ \
-- |  __/>  <| | |_\__ \ (__| | |  __/  __/ | | |
--  \___/_/\_\_|\__|___/\___|_|  \___|\___|_| |_|
local awful = require("awful")
local gears = require("gears")
local wibox = require("wibox")
local beautiful = require("beautiful")
local xresources = require("beautiful.xresources")
local dpi = xresources.apply_dpi
-- local naughty = require("naughty")

-- Appearance
local icon_font = "Iosevka Nerd Font 45"
local poweroff_text_icon = " "
local reboot_text_icon = " "
local suspend_text_icon = " "
local exit_text_icon = ""
local lock_text_icon = ""
local exitscreen_bg = beautiful.background .. "aa"

local button_bg = "#1d2021"
local button_size = dpi(120)

-- Commands
local poweroff_command =
    function() awful.spawn.with_shell("systemctl poweroff") end
local reboot_command = function() awful.spawn.with_shell("systemctl reboot") end
local suspend_command = function()
    lock_screen_show()
    awful.spawn.with_shell("systemctl suspend")
end
local exit_command = function() awesome.quit() end
local lock_command = function() awful.spawn.with_shell("~/.bin/lock") end

local rrect = function(radius)
    return function(cr, width, height)
        gears.shape.rounded_rect(cr, width, height, radius)
    end
end

local colorize_text = function(txt, fg)
    return "<span foreground='" .. fg .."'>" .. txt .. "</span>"
end

local add_hover_cursor = function(widget, hover_cursor)
    local original_cursor = "left_ptr"

    widget:connect_signal("mouse::enter", function ()
        local w = mouse.current_wibox
        if w then
            w.cursor = hover_cursor
        end
    end)

    widget:connect_signal("mouse::leave", function ()
        local w = mouse.current_wibox
        if w then
            w.cursor = original_cursor
        end
    end)
end

-- Helper function that generates the clickable buttons
local create_button = function(symbol, hover_color, text, command)
    local icon = wibox.widget {
        forced_height = button_size,
        forced_width = button_size,
        align = "center",
        valign = "center",
        font = icon_font,
        text = symbol,
        widget = wibox.widget.textbox()
    }

    local button = wibox.widget {
        {nil, icon, expand = "none", layout = wibox.layout.align.horizontal},
        forced_height = button_size,
        forced_width = button_size,
        border_width = dpi(3),
        border_color = button_bg,
        shape = rrect(10),
        bg = button_bg,
        widget = wibox.container.background
    }

    -- Bind left click to run the command
    button:buttons(gears.table.join(
                       awful.button({}, 1, function() command() end)))

    -- Change color on hover
    button:connect_signal("mouse::enter", function()
        icon.markup = colorize_text(icon.text, hover_color)
        button.border_color = hover_color
    end)
    button:connect_signal("mouse::leave", function()
        icon.markup = colorize_text(icon.text, beautiful.foreground)
        button.border_color = button_bg
    end)

    -- Use helper function to change the cursor on hover
    add_hover_cursor(button, "hand1")

    return button
end

-- Create the buttons
local poweroff = create_button(poweroff_text_icon, beautiful.red,
                               "Poweroff", poweroff_command)
local reboot = create_button(reboot_text_icon, beautiful.green, "Reboot", reboot_command)
local suspend = create_button(suspend_text_icon, beautiful.yellow, "Suspend", suspend_command)
local exit = create_button(exit_text_icon, beautiful.red, "Exit", exit_command)
local lock = create_button(lock_text_icon, beautiful.green, "Lock", lock_command)

-- Create the exit screen wibox
exit_screen = wibox({visible = false, ontop = true, type = "dock"})
awful.placement.maximize(exit_screen)

exit_screen.bg = beautiful.exit_screen_bg or exitscreen_bg or "#282828"
exit_screen.fg = beautiful.exit_screen_fg or beautiful.wibar_fg or "#ebdbb2"

local exit_screen_grabber
function exit_screen_hide()
    awful.keygrabber.stop(exit_screen_grabber)
    exit_screen.visible = false
end
function exit_screen_show()
    exit_screen_grabber = awful.keygrabber.run(
        function(_, key, event)
            -- Ignore case
            key = key:lower()

            if event == "release" then return end

            if key == 's' then
                suspend_command()
                exit_screen_hide()
                -- 'e' for exit
            elseif key == 'e' then
                exit_command()
            elseif key == 'l' then
                exit_screen_hide()
                lock_command()
            elseif key == 'p' then
                poweroff_command()
            elseif key == 'r' then
                reboot_command()
            elseif key == 'escape' or key == 'q' or key == 'x' then
                exit_screen_hide()
            end
        end)
    exit_screen.visible = true
end

exit_screen:buttons(gears.table.join( -- Left click - Hide exit_screen
awful.button({}, 1, function() exit_screen_hide() end),
-- Middle click - Hide exit_screen
awful.button({}, 2, function() exit_screen_hide() end),
-- Right click - Hide exit_screen
awful.button({}, 3, function() exit_screen_hide() end)))

-- Item placement
exit_screen:setup{
    nil,
    {
        nil,
        {
            poweroff,
            reboot,
            suspend,
            exit,
            lock,
            spacing = dpi(50),
            layout = wibox.layout.fixed.horizontal
        },
        expand = "none",
        layout = wibox.layout.align.horizontal
    },
    expand = "none",
    layout = wibox.layout.align.vertical
}

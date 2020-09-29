local gears = require("gears")
local wibox = require("wibox")
local awful = require("awful")
local beautiful = require("beautiful")
local dpi = beautiful.xresources.apply_dpi
local lain = require("lain")
local markup = lain.util.markup
local margin = wibox.container.margin

function colorize(icon, color)
    return gears.color.recolor_image(icon, color)
end

-- Modules
require("statusbar.modules.time")
require("statusbar.modules.systray")
require("statusbar.modules.battery")
require("statusbar.modules.memory")
require("statusbar.modules.cpu")
require("statusbar.modules.netspeed")
require("statusbar.modules.volume")
require("statusbar.modules.temp")
require("statusbar.modules.taglist")
require("statusbar.modules.playerctl")

local function set_wallpaper(s)
    -- Wallpaper
    if beautiful.wallpaper then
        local wallpaper = beautiful.wallpaper
        -- If wallpaper is a function, call it with the screen
        if type(wallpaper) == "function" then
            wallpaper = wallpaper(s)
        end
        gears.wallpaper.maximized(wallpaper, s, true)
    end
end

-- Re-set wallpaper when a screen's geometry changes (e.g. different resolution)
screen.connect_signal("property::geometry", set_wallpaper)

awful.screen.connect_for_each_screen(function(s)
    -- Wallpaper
    set_wallpaper(s)

    -- Create a taglist widget
    s.taglist = awful.widget.taglist {
        screen  = s,
        filter  = awful.widget.taglist.filter.all,
        buttons = taglist_buttons
    }

    -- Create the wibox
    s.wibox = awful.wibar({
        position = "top",
        screen = s,
        height = beautiful.statusbar_height,
        width = s.geometry.width,
    })

    -- Add widgets to the wibox
    s.wibox:setup {
        layout = wibox.layout.align.horizontal,
        expand = "none",
        {
            margin(launcher, dpi(5), dpi(5)),
            s.taglist,

            margin(spotifyicon, dpi(5), dpi(5), dpi(6), dpi(8)),
            margin(playerctl_widget, dpi(0), dpi(12), dpi(0), dpi(2)),

            layout = wibox.layout.fixed.horizontal,
        },
        {
            wibox.container.margin(clock, dpi(10), dpi(10), dpi(5), dpi(10)),
            layout = wibox.layout.fixed.horizontal,
        },
        {
            -- Netstatus
            margin(neticon, dpi(5), dpi(5), dpi(6), dpi(8)),
            margin(downicon, dpi(5), dpi(5), dpi(6), dpi(8)),
            margin(netdown, dpi(0), dpi(8), dpi(0), dpi(4)),
            margin(upicon, dpi(5), dpi(5), dpi(6), dpi(8)),
            margin(netup.widget, dpi(0), dpi(8), dpi(0), dpi(4)),

            -- Volume
            margin(volicon, dpi(5), dpi(5), dpi(6), dpi(8)),
            margin(vol.widget, dpi(0), dpi(8), dpi(0), dpi(4)),

            -- Temperature
            margin(tempicon, dpi(5), dpi(5), dpi(6), dpi(8)),
            margin(temp.widget, dpi(0), dpi(8), dpi(0), dpi(4)),

            -- CPU
            margin(cpuicon, dpi(5), dpi(5), dpi(6), dpi(8)),
            margin(cpu.widget, dpi(0), dpi(8), dpi(0), dpi(4)),

            -- Memory
            margin(memicon, dpi(5), dpi(5), dpi(6), dpi(8)),
            margin(mem.widget, dpi(0), dpi(8), dpi(0), dpi(4)),

            -- Battery
            margin(baticon, dpi(5), dpi(5), dpi(6), dpi(8)),
            margin(bat.widget, dpi(0), dpi(8), dpi(0), dpi(4)),

            margin(systray, dpi(0), dpi(2), dpi(4), dpi(4)),
            -- s.mylayoutbox,
            layout = wibox.layout.fixed.horizontal,
        },
    }
end)

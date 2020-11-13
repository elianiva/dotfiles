local gears = require("gears")
local wibox = require("wibox")
local awful = require("awful")
local beautiful = require("beautiful")
local dpi = beautiful.xresources.apply_dpi
local margin = wibox.container.margin

local text_wrapper = function(widget, left, right, top, bottom)
  left = left or 0
  right = right or 6
  top = top or 4
  bottom = bottom or 4

  return margin(widget, dpi(left), dpi(right), dpi(top), dpi(bottom))
end

local icon_wrapper = function(icon, left, right, top, bottom)
  left = left or 5
  right = right or 5
  top = top or 8
  bottom = bottom or 8

  return margin(icon, dpi(left), dpi(right), dpi(top), dpi(bottom))
end

-- Modules
local systray = require("statusbar.modules.systray")

local launcher = require("statusbar.modules.launcher")
local clock = require("statusbar.modules.clock")
local battery = require("statusbar.modules.battery")
local memory = require("statusbar.modules.memory")
local cpu = require("statusbar.modules.cpu")
local netspeed = require("statusbar.modules.netspeed")
local volume = require("statusbar.modules.volume")
local temp = require("statusbar.modules.temp")
local taglist = require("statusbar.modules.taglist")
local playerctl = require("statusbar.modules.playerctl")
local todo = require("statusbar.modules.todo")

local function set_wallpaper(s)
  -- Wallpaper
  if beautiful.wallpaper then
    local wallpaper = beautiful.wallpaper
    -- If wallpaper is a function, call it with the screen
    if type(wallpaper) == "function" then wallpaper = wallpaper(s) end
    gears.wallpaper.maximized(wallpaper, s, true)
  end
end

-- Re-set wallpaper when a screen's geometry changes (e.g. different resolution)
screen.connect_signal("property::geometry", set_wallpaper)

awful.screen.connect_for_each_screen(function(s)
  -- Wallpaper
  set_wallpaper(s)

  -- Create a taglist widget
  s.taglist = taglist.widget(s)

  -- Create the wibox
  s.wibox = awful.wibar({
    position = "top",
    screen = s,
    height = theme.statusbar_height,
    width = s.geometry.width
  })

  -- Add widgets to the wibox
  s.wibox:setup{
    layout = wibox.layout.align.horizontal,
    expand = "none",
    {
      text_wrapper(launcher.widget, dpi(5), dpi(5), dpi(0), dpi(0)),
      s.taglist,

      icon_wrapper(playerctl.icon),
      text_wrapper(playerctl.widget, dpi(0), dpi(12), dpi(0), dpi(0)),

      layout = wibox.layout.fixed.horizontal
    },
    {
      -- text_wrapper(clock, 10, 10, 5, 10), -- Clock
      text_wrapper(clock.widget, dpi(10), dpi(10), dpi(5), dpi(10)), -- Clock
      layout = wibox.layout.fixed.horizontal
    },
    {
      -- Netstatus
      icon_wrapper(netspeed.wifi_icon),
      icon_wrapper(netspeed.down_icon),
      text_wrapper(netspeed.down_speed),
      icon_wrapper(netspeed.up_icon),
      text_wrapper(netspeed.up_speed),

      icon_wrapper(volume.icon),
      text_wrapper(volume.widget), -- Volume
      icon_wrapper(temp.icon),
      text_wrapper(temp.widget), -- Temperature
      icon_wrapper(cpu.icon),
      text_wrapper(cpu.widget), -- CPU
      icon_wrapper(memory.icon),
      text_wrapper(memory.widget), -- Memory
      icon_wrapper(battery.icon),
      text_wrapper(battery.widget, 0, 0), -- Battery
      text_wrapper(todo, 0, 5, 8, 8), -- Todo

      margin(systray.widget, dpi(0), dpi(2), dpi(4), dpi(4)),
      -- s.mylayoutbox,
      layout = wibox.layout.fixed.horizontal
    }
  }
end)

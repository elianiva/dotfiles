local gears = require("gears")
local wibox = require("wibox")
local awful = require("awful")
local beautiful = require("beautiful")
local dpi = beautiful.xresources.apply_dpi
local lain = require("lain")
local markup = lain.util.markup
local margin = wibox.container.margin
local bg = wibox.container.background

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


function colorize(icon, color)
    return gears.color.recolor_image(icon, color)
end

-- Modules
require("statusbar.modules.clock")
require("statusbar.modules.systray")
require("statusbar.modules.battery")
require("statusbar.modules.memory")
require("statusbar.modules.cpu")
require("statusbar.modules.netspeed")
require("statusbar.modules.volume")
require("statusbar.modules.temp")
require("statusbar.modules.taglist")
require("statusbar.modules.playerctl")

local todo = require("statusbar.modules.todo")

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
    height = theme.statusbar_height,
    width = s.geometry.width,
  })

  -- Add widgets to the wibox
  s.wibox:setup {
    layout = wibox.layout.align.horizontal,
    expand = "none",
    {
      text_wrapper(launcher, 5, 5, 0, 0),
      s.taglist,

      icon_wrapper(player_icon), text_wrapper(playerctl_widget, 0, 12, 0, 2),

      layout = wibox.layout.fixed.horizontal,
    },
    {
      text_wrapper(clock, 10, 10, 5, 10), -- Clock
      layout = wibox.layout.fixed.horizontal,
    },
    {
      -- Netstatus
      icon_wrapper(wifi_icon),
      icon_wrapper(down_icon), text_wrapper(down_speed),
      icon_wrapper(up_icon), text_wrapper(netspeed.widget),

      icon_wrapper(vol_icon), text_wrapper(vol.widget), -- Volume
      icon_wrapper(temp_icon), text_wrapper(temp.widget), -- Temperature
      icon_wrapper(cpu_icon), text_wrapper(cpu.widget), -- CPU
      icon_wrapper(mem_icon), text_wrapper(mem.widget), -- Memory
      icon_wrapper(bat_icon), text_wrapper(bat.widget, 0, 0), -- Battery
      text_wrapper(todo, 0, 5, 8, 8), -- Todo

      margin(systray, dpi(0), dpi(2), dpi(4), dpi(4)),
      -- s.mylayoutbox,
      layout = wibox.layout.fixed.horizontal,
    },
  }
end
)

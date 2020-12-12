local wibox = require("wibox")
local awful = require("awful")
local colorize = require"main.helpers".colorize
local markup = require"main.helpers".markup
local gears = require("gears")

local HOME = os.getenv("HOME")

local volume_off = HOME .. "/.config/awesome/statusbar/modules/volume/volume_off.svg"
local volume_mute = HOME .. "/.config/awesome/statusbar/modules/volume/volume_mute.svg"
local volume_low = HOME .. "/.config/awesome/statusbar/modules/volume/volume_down.svg"
local volume_high = HOME .. "/.config/awesome/statusbar/modules/volume/volume_up.svg"

local M = {}

-- Volume
M.icon = wibox.widget.imagebox(colorize(volume_low, theme.widget_main_color))

local get_vol_status = [[
  sh -c "
    pacmd list-sinks | awk '/\\* index: /{nr[NR+7];nr[NR+11]}; NR in nr'
  "
]]

local set_volume = function(widget, stdout)
  local volume = tonumber(stdout:match('(%d+)%% /'))
  local muted = stdout:match('muted:(%s+)[yes]')

  if muted then
    M.icon:set_image(colorize(volume_off, theme.foreground))
    widget:set_markup(markup("muted", {fg = theme.foreground}))
  else

    if volume <= 20 then
      M.icon:set_image(colorize(volume_mute, theme.widget_main_color))
    elseif volume <= 60 then
      M.icon:set_image(colorize(volume_low, theme.widget_main_color))
    else
      M.icon:set_image(colorize(volume_high, theme.widget_main_color))
    end

    widget:set_markup(markup(tostring(volume).."%", {fg = theme.foreground}))
  end
end

M.widget = awful.widget.watch(get_vol_status, 120, function(widget, stdout)
  set_volume(widget, stdout)
end)

M.widget:buttons(gears.table.join(
  awful.button({}, 4, function()
    awful.spawn.easy_async("pulsemixer --change-volume +2", function()
      -- send signal AFTER the volume has changed
      awesome.emit_signal("volume_change")
    end)
  end),
  awful.button({}, 5, function()
    awful.spawn.easy_async("pulsemixer --change-volume -2", function()
      -- send signal AFTER the volume has changed
      awesome.emit_signal("volume_change")
    end)
  end)
))

awesome.connect_signal("volume_change", function()
  awful.spawn.easy_async_with_shell(get_vol_status, function(stdout)
    set_volume(M.widget, stdout)
  end)
end)

return M

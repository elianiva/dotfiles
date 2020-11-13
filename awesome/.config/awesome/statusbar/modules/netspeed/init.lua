local wibox = require("wibox")
local lain = require("lain")
local markup = lain.util.markup
local colorize = require("main.helpers").colorize

local up = os.getenv("HOME") .. "/.config/awesome/statusbar/modules/netspeed/up.svg"
local down = os.getenv("HOME") .. "/.config/awesome/statusbar/modules/netspeed/down.svg"
local wifi_off = os.getenv("HOME") .. "/.config/awesome/statusbar/modules/netspeed/wifi_off.svg"
local wifi_on = os.getenv("HOME") .. "/.config/awesome/statusbar/modules/netspeed/wifi_on.svg"

local M = {}

-- Netspeed
M.up_icon = wibox.widget.imagebox(
  colorize(up, theme.widget_main_color)
)

M.down_icon = wibox.widget.imagebox(
  colorize(down, theme.widget_main_color)
)

M.wifi_icon = wibox.widget.imagebox()
M.down_speed = wibox.widget.textbox()

M.up_speed = lain.widget.net({
  units = 1024,
  settings = function()
    if wifi_state ~= "off" then
      M.wifi_icon:set_image(colorize(wifi_on, theme.widget_main_color))
      widget:set_markup(markup(theme.foreground, net_now.sent .. "KB"))
      M.down_speed:set_markup(markup(theme.foreground, net_now.received .. "KB"))
    else
      M.wifi_icon:set_image(colorize(wifi_off, theme.widget_main_color))
      widget:set_markup("")
      M.down_speed:set_markup("")
    end
  end
}).widget -- call the actual lain widget

return M

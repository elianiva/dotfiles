local wibox = require("wibox")
local lain = require("lain")
local markup = lain.util.markup

local up = os.getenv("HOME") .. "/.config/awesome/statusbar/modules/netspeed/up.svg"
local down = os.getenv("HOME") .. "/.config/awesome/statusbar/modules/netspeed/down.svg"
local wifi_off = os.getenv("HOME") .. "/.config/awesome/statusbar/modules/netspeed/wifi_off.svg"
local wifi_on = os.getenv("HOME") .. "/.config/awesome/statusbar/modules/netspeed/wifi_on.svg"

-- Netspeed
upicon = wibox.widget.imagebox(
  colorize(up, theme.widget_main_color)
)

downicon = wibox.widget.imagebox(
  colorize(down, theme.widget_main_color)
)

neticon = wibox.widget.imagebox()
netdown = wibox.widget.textbox()
netup = lain.widget.net({
  units = 1024,
  settings = function()
    if wifi_state ~= "off" then
      neticon:set_image(colorize(wifi_on, theme.widget_main_color))
      widget:set_markup(markup(theme.foreground, net_now.sent .. "KB"))
      netdown:set_markup(markup(theme.foreground, net_now.received .. "KB"))
    else
      neticon:set_image(colorize(wifi_off, theme.widget_main_color))
      widget:set_markup("")
      netdown:set_markup("")
    end
  end
})


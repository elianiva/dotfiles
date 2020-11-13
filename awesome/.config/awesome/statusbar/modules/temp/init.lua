local wibox = require("wibox")
local lain = require("lain")
local markup = lain.util.markup
local icon = os.getenv("HOME") ..  "/.config/awesome/statusbar/modules/temp/icon.svg"
local colorize = require("main.helpers").colorize

local M = {}

-- Temperature
M.icon = wibox.widget.imagebox(colorize(icon, theme.widget_main_color))

M.widget = lain.widget.temp({
  tempfile = "/sys/devices/virtual/thermal/thermal_zone0/temp",
  settings = function()
    widget:set_markup(
      markup(theme.foreground, math.floor(coretemp_now) .. "°C"))
  end
}).widget -- call the actual lain widget

return M

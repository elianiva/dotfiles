local wibox = require("wibox")
local lain = require("lain")
local markup = lain.util.markup
local icon = os.getenv("HOME") .. "/.config/awesome/statusbar/modules/temp/icon.svg"

-- Temperature
temp_icon = wibox.widget.imagebox(
  colorize(icon, theme.widget_main_color)
)

temp = lain.widget.temp({
  tempfile = "/sys/devices/virtual/thermal/thermal_zone0/temp",
  settings = function()
    widget:set_markup(markup(theme.foreground, coretemp_now .. " °C"))
  end
})


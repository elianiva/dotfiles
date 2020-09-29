local wibox = require("wibox")
local lain = require("lain")
local markup = lain.util.markup

-- Temperature
tempicon = wibox.widget.imagebox(
    colorize(theme.temp_icon, theme.widget_main_color)
)
temp = lain.widget.temp({
    tempfile = "/sys/devices/virtual/thermal/thermal_zone0/temp",
    settings = function()
        widget:set_markup(markup(theme.foreground, coretemp_now .. " °C"))
    end
})


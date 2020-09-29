local wibox = require("wibox")
local lain = require("lain")
local markup = lain.util.markup

-- CPU
cpuicon = wibox.widget.imagebox(
    colorize(theme.cpu_icon, theme.widget_main_color)
)
cpu = lain.widget.cpu({
    timeout = 2,
    settings = function()
        widget:set_markup(markup(theme.foreground, cpu_now.usage .. "%"))
    end
})


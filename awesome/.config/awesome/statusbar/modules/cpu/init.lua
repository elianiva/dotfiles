local wibox = require("wibox")
local lain = require("lain")
local markup = lain.util.markup
local icon = os.getenv("HOME") .. "/.config/awesome/statusbar/modules/cpu/icon.svg"

-- CPU
cpuicon = wibox.widget.imagebox(
  colorize(icon, theme.widget_main_color)
)
cpu = lain.widget.cpu({
  timeout = 2,
  settings = function()
    widget:set_markup(markup(theme.foreground, cpu_now.usage .. "%"))
  end
})


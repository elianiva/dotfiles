local wibox = require("wibox")
local lain = require("lain")
local markup = lain.util.markup
local icon = os.getenv("HOME") .. "/.config/awesome/statusbar/modules/memory/icon.svg"

-- Memory
mem_icon = wibox.widget.imagebox(
  colorize(icon, theme.widget_main_color)
)

mem = lain.widget.mem({
  timeout = 2,
  settings = function()
    widget:set_markup(markup(theme.foreground, mem_now.perc .. "%"))
  end
})


local wibox = require("wibox")
local lain = require("lain")
local markup = lain.util.markup

-- Memory
memicon = wibox.widget.imagebox(
    colorize(theme.memory_icon, theme.widget_main_color)
)
mem = lain.widget.mem({
    timeout = 2,
    settings = function()
        widget:set_markup(markup(theme.foreground, mem_now.perc .. "%"))
    end
})


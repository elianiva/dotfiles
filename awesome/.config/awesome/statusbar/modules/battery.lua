local wibox = require("wibox")
local lain = require("lain")
local markup = lain.util.markup

-- Battery
baticon = wibox.widget.imagebox(
    colorize(theme.battery_icon, theme.widget_main_color)
)

bat = lain.widget.bat({
    settings = function()
        if bat_now.status and bat_now.status ~= "N/A" then
            if bat_now.status == "Charging" then
                widget:set_markup(markup(theme.foreground, bat_now.perc .. "%+"))
            else
                widget:set_markup(markup(theme.foreground, bat_now.perc .. "% "))
            end
        else
            widget:set_markup(markup(theme.foreground, bat_now.perc .. " "))
        end
    end
})

local wibox = require("wibox")
local lain = require("lain")
local markup = lain.util.markup

-- Netspeed
upicon = wibox.widget.imagebox(
    colorize(theme.arrow_up, theme.widget_main_color)
)
downicon = wibox.widget.imagebox(
    colorize(theme.arrow_down, theme.widget_main_color)
)
neticon = wibox.widget.imagebox()
netdown = wibox.widget.textbox()
netup = lain.widget.net({
    units = 1024,
    settings = function()
        if wifi_state ~= "off" then
            neticon:set_image(colorize(theme.wifi_on, theme.widget_main_color))
            widget:set_markup(markup(theme.foreground, net_now.sent .. "KB"))
            netdown:set_markup(markup(theme.foreground, net_now.received .. "KB"))
        else
            neticon:set_image(colorize(theme.wifi_off, theme.widget_main_color))
            widget:set_markup("")
            netdown:set_markup("")
        end
    end
})


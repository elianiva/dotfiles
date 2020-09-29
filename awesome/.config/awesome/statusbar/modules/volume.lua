local wibox = require("wibox")
local lain = require("lain")
local markup = lain.util.markup

-- Volume
volicon = wibox.widget.imagebox(
    colorize(theme.volume_down, theme.widget_main_color
))
vol = lain.widget.pulse({
    settings = function()
        if volume_now.muted ~= "yes" then
            if not volume_now.right and tonumber(volume_now.right) <= 20 then
                volicon:set_image(colorize(theme.volume_mute, theme.widget_main_color))
            elseif not volume_now.right and tonumber(volume_now.right) <= 60 then
                volicon:set_image(colorize(theme.volume_down, theme.widget_main_color))
            else
                volicon:set_image(colorize(theme.volume_up, theme.widget_main_color))
            end
            widget:set_markup(markup(theme.foreground, volume_now.right .. "%"))
        else
            widget:set_markup(markup(theme.foreground, "Muted"))
        end
    end
})


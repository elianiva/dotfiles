local wibox = require("wibox")
local lain = require("lain")
local markup = lain.util.markup

local HOME = os.getenv("HOME")

local volume_off = HOME .. "/.config/awesome/statusbar/modules/volume/volume_off.svg"
local volume_mute = HOME .. "/.config/awesome/statusbar/modules/volume/volume_mute.svg"
local volume_down = HOME .. "/.config/awesome/statusbar/modules/volume/volume_down.svg"
local volume_up = HOME .. "/.config/awesome/statusbar/modules/volume/volume_up.svg"

-- Volume
vol_icon = wibox.widget.imagebox(
  colorize(volume_down, theme.widget_main_color
))

vol = lain.widget.pulse({
  settings = function()
    if volume_now.muted ~= "yes" then
      if not volume_now.right and tonumber(volume_now.right) <= 20 then
        vol_icon:set_image(colorize(volume_mute, theme.widget_main_color))
      elseif not volume_now.right and tonumber(volume_now.right) <= 60 then
        vol_icon:set_image(colorize(volume_down, theme.widget_main_color))
      else
        vol_icon:set_image(colorize(volume_up, theme.widget_main_color))
      end
      widget:set_markup(markup(theme.foreground, volume_now.right .. "%"))
    else
      widget:set_markup(markup(theme.foreground, "Muted"))
    end
  end
})


local wibox = require("wibox")
local lain = require("lain")
local markup = lain.util.markup
local icon = os.getenv("HOME") .. "/.config/awesome/statusbar/modules/battery/icon.svg"
local colorize = require("main.helpers").colorize

local M = {}

-- Battery
M.icon = wibox.widget.imagebox(
  colorize(icon, theme.widget_main_color)
)

M.widget = lain.widget.bat({
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
}).widget -- call the actual lain widget

return M

local wibox = require("wibox")
local awful = require("awful")
local icon = os.getenv("HOME") .. "/.config/awesome/statusbar/modules/temp/icon.svg"
local colorize = require("main.helpers").colorize
local markup = require("main.helpers").markup

local M = {}

-- Temperature
M.icon = wibox.widget.imagebox(colorize(icon, theme.widget_main_color))

local get_temp_status = [[
  sh -c "
    sensors | awk '/^Core 0:/{gsub(/[^0-9]/, \" \"); print $2\"°C\"}'
  "
]]

M.widget = awful.widget.watch(get_temp_status, 5, function(widget, stdout)
	widget:set_markup(markup(stdout, { fg = theme.foreground }))
end)

return M

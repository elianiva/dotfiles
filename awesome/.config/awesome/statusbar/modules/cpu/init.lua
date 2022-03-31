local wibox = require("wibox")
local awful = require("awful")
local icon = os.getenv("HOME") .. "/.config/awesome/statusbar/modules/cpu/icon.svg"
local colorize = require("main.helpers").colorize
local markup = require("main.helpers").markup

local M = {}

-- CPU
M.icon = wibox.widget.imagebox(colorize(icon, theme.widget_main_color))

local get_cpu_status = [[
  sh -c "
    top -bn1 | awk '/Cpu\(s\)/ {print (100-$8)\"%\"}'
  "
]]

M.widget = awful.widget.watch(get_cpu_status, 5, function(widget, stdout)
	widget:set_markup(markup(stdout, { fg = theme.foreground }))
end)

return M

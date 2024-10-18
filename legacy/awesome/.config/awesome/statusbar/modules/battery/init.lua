local wibox = require("wibox")
local awful = require("awful")
local colorize = require("main.helpers").colorize
local markup = require("main.helpers").markup
local icon = os.getenv("HOME") .. "/.config/awesome/statusbar/modules/battery/icon.svg"

local M = {}

-- Battery
M.icon = wibox.widget.imagebox(colorize(icon, theme.widget_main_color))

local get_bat_status = [[
  sh -c "
    acpi | sed \"s/,//g\" | awk '{if ($3 == \"Discharging\"){print $4; exit} else {print $4\"+ \"}}' | tr -d \"\n\"
  "
]]

M.widget = awful.widget.watch(get_bat_status, 60, function(widget, stdout)
	widget:set_markup(markup(stdout, { fg = theme.foreground }))
end)

return M

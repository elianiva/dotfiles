local wibox = require("wibox")
local awful = require("awful")
local icon = os.getenv("HOME") .. "/.config/awesome/statusbar/modules/memory/icon.svg"
local colorize = require("main.helpers").colorize
local markup = require("main.helpers").markup

local M = {}

-- Memory
M.icon = wibox.widget.imagebox(colorize(icon, theme.widget_main_color))

local get_mem_status = [[
  sh -c "
    free -h | awk '/^Mem/ { print $3 }' | sed s/i//g
  "
]]

M.widget = awful.widget.watch(get_mem_status, 5, function(widget, stdout)
	widget:set_markup(markup(stdout, { fg = theme.foreground }))
end)

return M

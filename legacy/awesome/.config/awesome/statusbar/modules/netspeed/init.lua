local wibox = require("wibox")
local awful = require("awful")
local markup = require("main.helpers").markup
local colorize = require("main.helpers").colorize

local up = os.getenv("HOME") .. "/.config/awesome/statusbar/modules/netspeed/up.svg"
local down = os.getenv("HOME") .. "/.config/awesome/statusbar/modules/netspeed/down.svg"
-- local wifi_off = os.getenv("HOME") .. "/.config/awesome/statusbar/modules/netspeed/wifi_off.svg"
local wifi_on = os.getenv("HOME") .. "/.config/awesome/statusbar/modules/netspeed/wifi_on.svg"

local M = {}

-- Netspeed
M.up_icon = wibox.widget.imagebox(colorize(up, theme.widget_main_color))
M.down_icon = wibox.widget.imagebox(colorize(down, theme.widget_main_color))

M.wifi_icon = wibox.widget.imagebox(colorize(wifi_on, theme.widget_main_color))

local up_old = 0
local down_old = 0

local get_up = [[
  sh -c "cat /sys/class/net/[w]*/statistics/tx_bytes"
]]

local get_down = [[
  sh -c "cat /sys/class/net/[w]*/statistics/rx_bytes"
]]

M.up = awful.widget.watch(get_up, 2, function(widget, stdout)
	local num
	if up_old == 0 then
		num = 0
	else
		num = math.floor(((tonumber(stdout) - up_old) / 1024) / 2)
	end
	widget:set_markup(markup(tostring(num) .. "KiB", { fg = theme.foreground }))
	up_old = tonumber(stdout)
end)

M.down = awful.widget.watch(get_down, 2, function(widget, stdout)
	local num
	if down_old == 0 then
		num = 0
	else
		num = math.floor(((tonumber(stdout) - down_old) / 1024) / 2)
	end
	widget:set_markup(markup(tostring(num) .. "KiB", { fg = theme.foreground }))
	down_old = tonumber(stdout)
end)

return M

local gears = require("gears")
local wibox = require("wibox")
local awful = require("awful")
local colorize = require("main.helpers").colorize
local dpi = require("beautiful.xresources").apply_dpi
local icon = os.getenv("HOME") .. "/.config/awesome/statusbar/modules/clock/icon.svg"

local M = {}

-- Clock
M.icon = wibox.widget.imagebox(colorize(icon, theme.widget_main_color))

M.widget = wibox.widget.textclock("<span color='" .. theme.foreground .. "'>%a, %I:%M %p</span>")

-- Calendar Widget
M.cal_shape = function(cr, width, height)
	gears.shape.rounded_rect(cr, width, height, false, false, true, true, 12)
end

M.month_calendar = awful.widget.calendar_popup.month({
	start_sunday = false,
	spacing = dpi(10),
	font = theme.font,
	long_weekdays = true,
	margin = dpi(8),
	style_month = { border_width = 0, shape = M.cal_shape, padding = dpi(25) },
	style_header = { border_width = 0, bg_color = theme.black },
	style_weekday = { border_width = 0, bg_color = theme.black },
	style_normal = { border_width = 0, bg_color = theme.black, fg_color = theme.grey },
	style_focus = { border_width = 0, bg_color = theme.black, fg_color = theme.widget_main_color },
})

-- Attach calentar to clock_widget
M.month_calendar:attach(M.widget, "tc", { on_pressed = true, on_hover = false })

return M

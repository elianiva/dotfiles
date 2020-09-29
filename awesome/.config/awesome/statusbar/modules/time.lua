local gears = require("gears")
local wibox = require("wibox")
local awful = require("awful")
local dpi = require("beautiful.xresources").apply_dpi

-- Clock
clock = wibox.widget.textclock("<span color='" .. theme.foreground .."'>%a, %I:%M %p</span>")

-- Calendar Widget
cal_shape = function(cr, width, height)
   gears.shape.rounded_rect(cr, width, height, false, false, true, true, 12)
end

month_calendar = awful.widget.calendar_popup.month({
   start_sunday = false,
   spacing = dpi(10),
   font = theme.font,
   long_weekdays = true,
   margin = dpi(8), -- 10
   style_month = {border_width = 0, padding = 12, shape = cal_shape, padding = 25},
   style_header = {border_width = 0, bg_color = theme.black},
   style_weekday = {border_width = 0, bg_color = theme.black},
   style_normal = {border_width = 0, bg_color = theme.black},
   style_focus = {border_width = 0, bg_color = theme.yellow},
})

-- Attach calentar to clock_widget
month_calendar:attach(clock, "tc" , { on_pressed = true, on_hover = false })

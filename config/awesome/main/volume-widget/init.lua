local wibox = require("wibox")
local awful = require("awful")
local gears = require("gears")
local beautiful = require("beautiful")
local dpi = beautiful.xresources.apply_dpi
local colorize = require("main.helpers").colorize

local offsetx = dpi(64)
local offsety = dpi(300)
local screen = awful.screen.focused()

local volume_up = os.getenv("HOME") .. "/.config/awesome/main/volume-widget/volume_up.svg"

local M = {}

function M.setup()
	-- create the volume_adjust component
	local volume_adjust = wibox({
		screen = awful.screen.focused(),
		x = screen.geometry.width - offsetx,
		y = (screen.geometry.height / 2) - (offsety / 2),
		width = dpi(48),
		height = offsety,
		shape = gears.shape.rect,
		visible = false,
		ontop = true,
	})

	local volume_bar = wibox.widget({
		widget = wibox.widget.progressbar,
		shape = gears.shape.rounded_bar,
		color = theme.widget_main_color,
		background_color = theme.grey_alt,
		max_value = 100,
		value = 0,
	})

	volume_adjust:setup({
		layout = wibox.layout.align.vertical,
		{
			wibox.container.margin(volume_bar, dpi(14), dpi(20), dpi(20), dpi(20)),
			forced_height = offsety * 0.75,
			direction = "east",
			layout = wibox.container.rotate,
		},
		wibox.container.margin(
			wibox.widget({
				image = colorize(volume_up, theme.widget_main_color),
				widget = wibox.widget.imagebox,
			}),
			dpi(10),
			dpi(10),
			dpi(14),
			dpi(14)
		),
	})

	-- create a 4 second timer to hide the volume adjust
	-- component whenever the timer is started
	local volume_timer = gears.timer({
		timeout = 4,
		autostart = true,
		callback = function()
			volume_adjust.visible = false
		end,
	})

	-- show volume-adjust when "volume_change" signal is emitted
	awesome.connect_signal("volume_change", function()
		-- set new volume value
		awful.spawn.easy_async("pulsemixer --get-volume", function(stdout)
			volume_bar.value = tonumber(stdout:gmatch("%d%d")())
		end)

		-- make volume_adjust component visible
		if volume_adjust.visible then
			volume_timer:again()
		else
			volume_adjust.visible = true
			volume_timer:start()
		end
	end)
end

return M

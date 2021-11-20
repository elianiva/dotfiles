local gears = require("gears")
local awful = require("awful")
local naughty = require("naughty")
local noop = require("main.helpers").noop

local M = gears.table.join(
	awful.key({}, "XF86AudioLowerVolume", function()
		awful.spawn.easy_async("pulsemixer --change-volume -2", function()
			-- send signal AFTER the volume has changed
			awesome.emit_signal("volume_change")
		end)
	end, { description = "lower the volume", group = "media" }),

	awful.key({}, "XF86AudioRaiseVolume", function()
		awful.spawn.easy_async("pulsemixer --change-volume +2", function()
			-- send signal AFTER the volume has changed
			awesome.emit_signal("volume_change")
		end)
	end, { description = "raise the volume", group = "media" }),

	awful.key({}, "XF86AudioMute", function()
		awful.spawn.easy_async("pulsemixer --toggle-mute", function()
			-- send signal AFTER the volume has changed
			awesome.emit_signal("volume_change")
		end)
	end, { description = "mute the audio", group = "media" }),

	awful.key({}, "XF86AudioPlay", function()
		awful.spawn.easy_async("playerctl --player=%any,chrome,chromium play-pause", function()
			naughty.notify({
				title = "Playerctl",
				text = "Audio toggled!",
			})
		end)
	end, { description = "toggle the audio", group = "media" }),

	awful.key({}, "XF86AudioNext", function()
		awful.spawn.easy_async("playerctl --player=%any,chrome,chromium next", function()
			naughty.notify({
				title = "Playerctl",
				text = "Audio toggled!",
			})
		end)
	end, { description = "toggle the audio", group = "media" }),

	awful.key({}, "XF86AudioPrev", function()
		awful.spawn.easy_async("playerctl --player=%any,chrome,chromium previous", function()
			naughty.notify({
				title = "Playerctl",
				text = "Audio toggled!",
			})
		end)
	end, { description = "toggle the audio", group = "media" }),

	-- Brightness
	awful.key({}, "XF86MonBrightnessDown", function()
		awful.spawn.easy_async("light -U 10", noop)
	end, { description = "decrease brightness", group = "brightness" }),

	awful.key({}, "XF86MonBrightnessUp", function()
		awful.spawn.easy_async("light -A 10", noop)
	end, { description = "increase brightness", group = "brightness" })
)

return M

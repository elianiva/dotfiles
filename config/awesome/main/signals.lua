-- Standard awesome library
local awful = require("awful")
local beautiful = require("beautiful")
local gears = require("gears")

local M = {}

M.setup = function()
	-- Signal function to execute when a new client appears.
	client.connect_signal("manage", function(c)
		-- Set the windows at the slave,
		-- i.e. put it at the end of others instead of setting it master.
		if not awesome.startup then
			awful.client.setslave(c)
		end

		-- -- rounded corners
		-- c.shape = function(cr, w, h)
		--   require"gears".shape.rounded_rect(cr, w, h, require"beautiful.xresources".apply_dpi(8))
		-- end

		if awesome.startup and not c.size_hints.user_position and not c.size_hints.program_position then
			-- Prevent clients from being unreachable after screen count changes.
			awful.placement.no_offscreen(c)
		end
	end)

	-- Focus follows mouse.
	client.connect_signal("mouse::enter", function(c)
		c:emit_signal("request::activate", "mouse_enter", { raise = false })
	end)

	client.connect_signal("property::fullscreen", function(c)
		if c.fullscreen then
			gears.timer.delayed_call(function()
				if c.valid then
					c:geometry(c.screen.geometry)
				end
			end)
		end
	end)

	client.connect_signal("focus", function(c)
		c.border_color = beautiful.border_focus
	end)

	client.connect_signal("unfocus", function(c)
		c.border_color = beautiful.border_normal
	end)
end

return M

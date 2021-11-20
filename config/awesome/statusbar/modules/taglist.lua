local gears = require("gears")
local awful = require("awful")
local modkey = require("main.variables").modkey

local M = {}

-- Create a wibox for each screen and add it
local taglist_buttons = gears.table.join(
	awful.button({}, 1, function(tag)
		tag:view_only()
	end),

	awful.button({ modkey }, 1, function(tag)
		if client.focus then
			client.focus:move_to_tag(tag)
		end
	end),

	awful.button({}, 3, awful.tag.viewtoggle),

	awful.button({ modkey }, 3, function(tag)
		if client.focus then
			client.focus:toggle_tag(tag)
		end
	end),

	awful.button({}, 4, function(t)
		awful.tag.viewnext(t.screen)
	end),
	awful.button({}, 5, function(t)
		awful.tag.viewprev(t.screen)
	end)
)

function M.widget(s)
	return awful.widget.taglist({
		screen = s,
		filter = awful.widget.taglist.filter.all,
		buttons = taglist_buttons,
	})
end

return M

local awful = require("awful")
local layouts = require("main.layouts")

local M = {}

M.setup = function()
	awful.screen.connect_for_each_screen(function(s)
		-- Each screen has its own tag table.
		awful.tag({ "一", "二", "三", "四", "五", "六" }, s, layouts[1])
	end)
end

return M

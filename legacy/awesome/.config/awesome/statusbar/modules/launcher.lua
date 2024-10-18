local awful = require("awful")
local beautiful = require("beautiful")
local menu = require("main.menu")

local M = {}

M.widget = awful.widget.launcher({
	image = beautiful.menu_icon,
	menu = menu.menu_items,
})

return M

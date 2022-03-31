local menubar = require("menubar")
local awful = require("awful")
local spawn = awful.spawn.with_shell
local hotkeys_popup = require("awful.hotkeys_popup")

local M = {}

local menu = {
	{
		"hotkeys",
		function()
			hotkeys_popup.show_help(nil, awful.screen.focused())
		end,
	},
	{
		"restart awesome",
		function()
			awesome.restart()
		end,
	},
	{
		"quit awesome",
		function()
			awesome.quit()
		end,
	},
}

local apps = {
	{
		"alacritty",
		function()
			spawn("alacritty &")
		end,
	},
	{
		"kitty",
		function()
			spawn("kitty &")
		end,
	},
	{
		"chrome",
		function()
			spawn("chrome &")
		end,
	},
	{
		"telegram",
		function()
			spawn("telegram &")
		end,
	},
	{
		"spotify",
		function()
			spawn("spotify &")
		end,
	},
}

local powermenu = {
	{
		"reboot",
		function()
			os.execute("reboot")
		end,
	},
	{
		"shutdown",
		function()
			os.execute("shutdown now")
		end,
	},
}

M.menu_items = awful.menu({
	items = {
		{ "awesome", menu },
		{ "apps", apps },
		{ "powermenu", powermenu },
	},
})

-- Set the terminal for applications that require it
menubar.utils.terminal = terminal

return M

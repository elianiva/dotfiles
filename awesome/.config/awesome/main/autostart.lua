local awful = require("awful")

local M = {}

M.setup = function()
	local cmds = {
		"clipmenud",
		"flameshot",
		"lxpolkit",
		"xfce4-power-manager",
		"fcitx5 --replace -d",
		-- "xrandr --output LVDS-1 --gamma 0.9:0.9:0.9",
	}

	for _, i in pairs(cmds) do
		awful.spawn.with_shell(i .. " &")
	end
end

return M

local awful = require "awful"

local M = {}

M.setup = function()
  local cmds = {
    "clipmenud",
    "flameshot",
    "lxpolkit",
    "setxkbmap -option caps:escape",
    "xfce4-power-manager",
    "fcitx5 --replace -d",
    "xrandr --output LVDS-1 --gamma 0.8:0.8:0.8",
  }

  for _, i in pairs(cmds) do
    awful.spawn.with_shell(i .. " &")
  end
end

return M

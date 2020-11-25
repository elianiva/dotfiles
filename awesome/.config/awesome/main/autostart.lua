local awful = require("awful")

do
  local cmds = {
    "lxpolkit",
    "clipmenud",
    "xfce4-power-manager",
    "picom --experimental-backends",
    "xrandr --output LVDS-1 --gamma 0.8:0.8:0.8",
  }

  for _,i in pairs(cmds) do
    awful.spawn.with_shell(i .. "&")
  end
end

local xrdb = require("beautiful.xresources").get_current_theme()

theme.background = xrdb.background
theme.foreground = xrdb.foreground

theme.black = xrdb.color0
theme.red = xrdb.color1
theme.green = xrdb.color2
theme.yellow = xrdb.color3
theme.blue = xrdb.color4
theme.magenta = xrdb.color5
theme.cyan = xrdb.color6
theme.white = xrdb.color7

-- theme.grey = "#3e3e3e"
theme.grey = xrdb.color8
theme.white_alt = "#555555"

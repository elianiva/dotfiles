local xresources = require("beautiful.xresources")
local theme_path = os.getenv("HOME") .. "/.config/awesome/themes/gruvbox/"

theme = {}

dofile(theme_path .. "colours.lua")
dofile(theme_path .. "elements.lua")
dofile(theme_path .. "layouts.lua")

theme.wallpaper     = os.getenv("HOME") .. "/pix/walls/babymetal/babymetal-red.jpg"
theme.awesome_icon  = theme_path .. "icons/babymetal.png"
theme.icon_theme    = "Numix"

return theme

-- vim: filetype=lua:expandtab:shiftwidth=4:tabstop=8:softtabstop=4:textwidth=80

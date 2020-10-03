local HOME_DIR = os.getenv("HOME")

local xresources = require("beautiful.xresources")
local theme_path = HOME_DIR .. "/.config/awesome/themes/gruvbox/"

theme = {}

dofile(theme_path .. "colours.lua")
dofile(theme_path .. "elements.lua")
dofile(theme_path .. "layouts.lua")

theme.wallpaper     = HOME_DIR .. "/pix/walls/babymetal/babymetal-red.jpg"
-- theme.wallpaper     = HOME_DIR .. "/pix/walls/Kill-la-Kill-Wallpaper-Matoi-Ryuuko.jpg"
theme.awesome_icon  = theme_path .. "icons/babymetal.png"
-- theme.awesome_icon  = theme_path .. "icons/killlakill.png"
theme.icon_theme    = "Numix"

return theme

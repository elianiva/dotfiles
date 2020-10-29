local HOME_DIR = os.getenv("HOME")

local xresources = require("beautiful.xresources")
local theme_path = HOME_DIR .. "/.config/awesome/themes/main/"

theme = {}

dofile(theme_path .. "colours.lua")
dofile(theme_path .. "elements.lua")

-- theme.wallpaper     = theme_path .. "img/babymetal.jpg"
-- theme.awesome_icon  = theme_path .. "icons/babymetal.png"

-- theme.wallpaper     = theme_path .. "img/ryuko-dark.png"
theme.wallpaper     = theme_path .. "img/ryuko-spring.jpg"
theme.awesome_icon  = theme_path .. "icons/killlakill.png"

theme.icon_theme    = "Numix"

return theme

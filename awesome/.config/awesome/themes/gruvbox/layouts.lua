local gfs = require("gears.filesystem")
local themes_path = gfs.get_themes_dir()
local theme_path = os.getenv("HOME") .. "/.config/awesome/themes/gruvbox/"

-- You can use your own layout icons like this:
theme.layout_tile = theme_path .. "layouts/tilew.png"
theme.layout_floating  = themes_path.."default/layouts/floatingw.png"
theme.layout_max = themes_path.."default/layouts/maxw.png"
theme.layout_fullscreen = themes_path.."default/layouts/fullscreenw.png"

local theme_path = os.getenv("HOME") .. "/.config/awesome/themes/main/"

theme = {} -- global namespace for theme

dofile(theme_path .. "colours.lua")
dofile(theme_path .. "elements.lua")
dofile(theme_path .. "naughty.lua")

return theme

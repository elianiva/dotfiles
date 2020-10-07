local naughty = require("naughty")
local theme_assets = require("beautiful.theme_assets")
local dpi = require("beautiful.xresources").apply_dpi

local themes_path = require("gears.filesystem").get_themes_dir()

local icons_dir = os.getenv("HOME") .. "/.config/awesome/themes/main/icons/"

-- theme.font          = "Iosevka 11"
theme.font  = "SF UI Display 11"
theme.taglist_font  = "M+ 2p Medium 11"
theme.taglist_fg_empty = theme.black_alt

theme.bg_normal     = theme.black
theme.bg_focus      = theme.yellow
theme.bg_urgent     = theme.red
theme.bg_minimize   = theme.grey
theme.bg_systray    = theme.black

theme.fg_normal     = theme.white
theme.fg_focus      = theme.black
theme.fg_urgent     = theme.black
theme.fg_minimize   = theme.white

theme.useless_gap   = dpi(4)
theme.border_width  = dpi(4)
theme.border_normal = theme.black .. "f0"
theme.border_focus  = theme.black .. "f0"
theme.border_marked = theme.red

theme.tasklist_bg_focus = theme.black
theme.tasklist_fg_focus = theme.yellow

theme.taglist_bg_focus = theme.black
theme.taglist_fg_focus = theme.yellow
-- theme.taglist_fg_focus = theme.red
theme.taglist_fg_empty = theme.white_alt
theme.taglist_fg_occupied = theme.white
theme.taglist_spacing = dpi(2)

theme.widget_main_color = theme.yellow
-- theme.widget_main_color = theme.red
theme.widget_red = theme.red
theme.widget_yelow = theme.yellow
theme.widget_green = theme.green
theme.widget_black = theme.black
theme.widget_transparent = "#00000000"

theme.titlebar_size = dpi(2)
theme.titlebar_bg_focus = theme.grey
theme.titlebar_bg_normal = theme.black .. "f2"

theme.notification_font = "SF UI Medium 11"
theme.notification_bg = theme.black
theme.notification_fg = theme.white
theme.notification_border_color = theme.white
theme.notification_border_width = dpi(2)

naughty.config.padding = dpi(10)
naughty.config.icon_dirs = {
    "/usr/share/icons/Numix/32/actions/",
    "/usr/share/icons/Numix/32/animations/",
    "/usr/share/icons/Numix/32/apps/",
    "/usr/share/icons/Numix/32/categories/",
    "/usr/share/icons/Numix/32/devices/",
    "/usr/share/icons/Numix/32/emblems/",
    "/usr/share/icons/Numix/32/emotes/",
    "/usr/share/icons/Numix/32/mimetypes/",
    "/usr/share/icons/Numix/32/places/",
    "/usr/share/icons/Numix/32/status/",
}
naughty.config.icon_formats = {"png", "svg"}
naughty.config.defaults.margin = dpi(10)
naughty.config.defaults.border_width = theme.notification_border_width
naughty.config.defaults.icon_size = dpi(100)
naughty.config.defaults.title = "System Notification"

-- Variables set for theming the menu:
-- menu_[bg|fg]_[normal|focus]
-- menu_[border_color|border_width]
theme.menu_submenu_icon = themes_path.."default/submenu.png"
theme.menu_height = dpi(24)
theme.menu_width  = dpi(180)

theme.tooltip_bg = "#282828"
theme.tooltip_fg = "#ebdbb2"
theme.tooltip_border_color = "#ebdbb2"

theme.statusbar_height = dpi(28)

local taglist_square_size = dpi(5)
theme.taglist_squares_sel = theme_assets.taglist_squares_sel(
    taglist_square_size, theme.fg_normal
)
theme.taglist_squares_unsel = theme_assets.taglist_squares_unsel(
    taglist_square_size, theme.fg_normal
)

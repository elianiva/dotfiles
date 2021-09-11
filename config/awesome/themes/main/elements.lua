local theme_assets = require("beautiful.theme_assets")
local dpi = require"beautiful.xresources".apply_dpi
local theme_path = os.getenv("HOME") .. "/.config/awesome/themes/main/"
local rrect = require"main.helpers".rrect

-- wallpaper and icon
theme.icon_theme = "Numix"
-- theme.wallpaper = theme_path .. "img/ryuko-spring.png"
-- theme.wallpaper = theme_path .. "img/autumn_gurl.png"
-- theme.wallpaper = theme_path .. "img/knowname1.png"
theme.wallpaper = os.getenv("HOME") .. "/Pictures/madoka.png"
-- theme.wallpaper = os.getenv("HOME") .. "/pix/gurl.jpg"
theme.menu_icon = theme_path .. "icons/killlakill.png"
-- theme.wallpaper     = theme_path .. "img/babymetal.jpg"
-- theme.menu_icon  = theme_path .. "icons/babymetal.png"

-- theme.font = "JetBrainsMono Nerd Font 10"
theme.font = "Inter 10"
theme.nerd_font = "JetBrainsMono Nerd Font 10"
theme.titlebar_font = "Inter 11"
theme.taglist_font = "M+ 2p Medium 11"
theme.color_name = "icy"

-- background stuff
theme.bg_normal = theme.black
theme.bg_focus = theme.yellow
theme.bg_urgent = theme.red
theme.bg_minimize = theme.grey

-- foreground stuff
theme.fg_normal = theme.white
theme.fg_focus = theme.black
theme.fg_urgent = theme.black
theme.fg_minimize = theme.white

-- gaps
theme.useless_gap = dpi(4)

-- systray
theme.systray_icon_spacing = dpi(6)
theme.bg_systray = theme.black
theme.systray_icon_size = dpi(10)

-- border stuff
theme.border_width = dpi(1)
theme.border_normal = theme.black
theme.border_focus = theme.black
theme.border_marked = theme.red

-- tasklist
theme.tasklist_bg_focus = theme.black
theme.tasklist_fg_focus = theme.yellow

-- widget
theme.widget_main_color = theme.blue
theme.widget_red = theme.red
theme.widget_yelow = theme.yellow
theme.widget_green = theme.green
theme.widget_black = theme.black
theme.widget_transparent = "#00000000"

-- titlebar
theme.titlebar_size = dpi(22)
theme.titlebar_bg_focus = theme.black
theme.titlebar_bg_normal = theme.black
theme.titlebar_fg_focus = theme.white
theme.titlebar_fg_normal = theme.white

-- notification
theme.notification_font = theme.font
theme.notification_bg = theme.black
theme.notification_fg = theme.white
theme.notification_border_color = theme.grey_alt
theme.notification_border_width = dpi(1)
theme.notification_max_width = dpi(600)
theme.notification_icon_size = dpi(100)
theme.notification_margin = dpi(10)

-- edge snap
theme.snap_bg = theme.white
theme.snap_shape = rrect(0)

-- hotkey font
theme.hotkeys_font = theme.font
theme.hotkeys_description_font = theme.font
theme.hotkeys_modifiers_fg = theme.yellow
theme.hotkeys_border_width = dpi(4)
theme.hotkeys_border_color = theme.black
theme.hotkeys_group_margin = dpi(10)

-- submenu
theme.menu_submenu_icon = theme_path .. "icons/submenu.svg"
theme.menu_height = dpi(24)
theme.menu_width = dpi(180)

-- window snap hint
theme.tooltip_bg = "#282828"
theme.tooltip_fg = "#ebdbb2"
theme.tooltip_border_color = "#ebdbb2"

-- statusbar
theme.statusbar_height = dpi(30)
theme.statusbar_visible = true
theme.statusbar_bg = theme.background

-- taglist
theme.taglist_bg_focus = theme.black
theme.taglist_fg_focus = theme.widget_main_color
theme.taglist_fg_empty = theme.grey
theme.taglist_fg_urgent = theme.black
theme.taglist_bg_urgent = theme.red
theme.taglist_fg_occupied = theme.white
theme.taglist_spacing = dpi(2)

local taglist_square_size = dpi(5)
theme.taglist_squares_sel = theme_assets.taglist_squares_sel(
  taglist_square_size, theme.fg_normal)
theme.taglist_squares_unsel = theme_assets.taglist_squares_unsel(
  taglist_square_size, theme.fg_normal)

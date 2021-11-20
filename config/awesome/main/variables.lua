local HOME_DIR = os.getenv("HOME")
local EDITOR = os.getenv("EDITOR")
local TERMINAL = os.getenv("TERMINAL")

local variables = {
	terminal = TERMINAL or "alacritty",
	editor = EDITOR or "nano",
	shot = HOME_DIR .. "/.scripts/shot",
	emoji_picker = HOME_DIR .. "/.scripts/emoji_picker",
	clipmenu = "clipmenu -p 'Clipboard: ' -theme "
		.. HOME_DIR
		.. "/.config/rofi/themes/"
		.. theme.color_name
		.. ".rasi",
	launcher = HOME_DIR .. "/.scripts/launcher ",
	modkey = "Mod4",
	altkey = "Mod1",
	ctrlkey = "Control",
}

return variables

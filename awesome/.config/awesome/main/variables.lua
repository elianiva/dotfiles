local HOME_DIR = os.getenv("HOME")
local EDITOR = os.getenv("EDITOR")

local M = {
    -- This is used later as the default terminal and editor to run.
    terminal = "alacritty",
    editor = EDITOR or "nano",
    shot = HOME_DIR .. "/.scripts/shot",
    emoji_picker = HOME_DIR .. "/.scripts/emoji_picker",
    clipmenu = "clipmenu -p 'Clipboard: ' -theme ~/.config/rofi/themes/gruvbox.rasi",
    launcher = HOME_DIR .. "/.scripts/launcher ",
    modkey = "Mod4",
    altkey = "Mod1",
    ctrlkey = "Control"
}

return M

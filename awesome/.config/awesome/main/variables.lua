local home = os.getenv("HOME")

local _M = {
    -- This is used later as the default terminal and editor to run.
    terminal = "alacritty",
    editor = os.getenv("EDITOR") or "nano",
    shot = os.getenv("HOME") .. "/.scripts/shot",
    emoji_picker = os.getenv("HOME") .. "/.scripts/emoji_picker",
    clipmenu = "clipmenu -p 'Clipboard: ' -theme ~/.config/rofi/themes/gruvbox.rasi",
    launcher = "sh ~/.scripts/launcher ",
    powermenu = "sh ~/.scripts/powermenu ",

    -- Default modkey.
    -- Usually, Mod4 is the key with a logo between Control and Alt.
    -- If you do not like this or do not have such a key,
    -- I suggest you to remap Mod4 to another key using xmodmap or other tools.
    -- However, you can use another modifier like Mod1, but it may interact with others.
    modkey = "Mod4",
    altkey = "Mod1",
    ctrlkey = "Control"
}

return _M

local menubar = require("menubar")
local beautiful = require("beautiful")
local awful = require("awful")
local hotkeys_popup = require("awful.hotkeys_popup")

-- Create a launcher widget and a main menu
menu = {
   { "hotkeys", function() hotkeys_popup.show_help(nil, awful.screen.focused()) end },
   -- { "manual", terminal .. " -e man awesome" },
   { "restart awesome", awesome.restart },
   { "quit awesome", function() awesome.quit() end },
}

powermenu = {
   { "reboot", function() os.execute("reboot") end },
   { "shutdown", function() os.execute("shutdown now") end },
}

menu = awful.menu({
    items = {
        {
            "awesome",
            menu,
        },
        {
            "powermenu",
            powermenu,
        },
    }
})

launcher = awful.widget.launcher({
        image = beautiful.awesome_icon,
        menu = menu
})

-- Menubar configuration
menubar.utils.terminal = terminal -- Set the terminal for applications that require it

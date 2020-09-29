-- If LuaRocks is installed, make sure that packages installed through it are
-- found (e.g. lgi). If LuaRocks is not installed, do nothing.
pcall(require, "luarocks.loader")
local gears = require("gears")
local awful = require("awful")
local wibox = require("wibox")
local beautiful = require("beautiful")
local menubar = require("menubar")
local hotkeys_popup = require("awful.hotkeys_popup")

require("awful.autofocus")
require("main.error-handling") -- error handling

-- Themes define colours, icons, font and wallpapers.
beautiful.init("~/.config/awesome/themes/gruvbox/theme.lua")

RC = {} -- global namespace, on top before require any modules
RC.vars = require("main.variables") -- user defined variables

modkey = RC.vars.modkey
altkey = RC.vars.altkey
ctrlkey = RC.vars.ctrlkey
terminal = RC.vars.terminal

-- Custom Local Library
local main = {
  layouts = require("main.layouts"),
  tags    = require("main.tags"),
  menu    = require("main.menu"),
  rules   = require("main.rules"),
}

-- Custom Local Library: Keys and Mouse Binding
local keybinds = {
  globalbuttons = require("keybinds.globalbuttons"),
  clientbuttons = require("keybinds.clientbuttons"),
  globalkeys    = require("keybinds.globalkeys"),
  bindtotags    = require("keybinds.bindtotags"),
  clientkeys    = require("keybinds.clientkeys"),
  mediakeys     = require("keybinds.mediakeys")
}

RC.layouts = main.layouts()
RC.tags = main.tags()
-- RC.mainmenu = awful.menu({ items = main.menu() }) -- in globalkeys
RC.launcher = awful.widget.launcher({
        image = beautiful.awesome_icon,
        menu = RC.mainmenu
})

menubar.utils.terminal = RC.vars.terminal

RC.globalkeys = keybinds.globalkeys()
RC.globalkeys = keybinds.bindtotags(RC.globalkeys)
RC.mediakeys =  keybinds.mediakeys()

-- Set root
root.buttons(keybinds.globalbuttons())
root.keys(gears.table.join(RC.globalkeys, RC.mediakeys))

require("main.volume-widget") -- Volume widget

-- Rules to apply to new clients (through the "manage" signal).
awful.rules.rules = main.rules(
  keybinds.clientkeys(),
  keybinds.clientbuttons()
)

require("statusbar.main") -- Load statusbar
require("main.signals") -- load events
require("main.titlebar") -- dual border
require("main.exitscreen") -- exitscreen
require("main.autostart") -- Autostart

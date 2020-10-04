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

local main = {
  layouts = require("main.layouts"), -- layouts
  tags    = require("main.tags"), -- tags
  menu    = require("main.menu"), -- menu
  rules   = require("main.rules"), -- define rules
  signals = require("main.signals"), -- connect events
  corners = require("main.titlebar"), -- dual border
  exitscreen = require("main.exitscreen"), -- exitscreen
  volume = require("main.volume-widget") -- Volume widget
}

main.signals()
main.corners()
main.exitscreen()
main.volume()

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
RC.launcher = awful.widget.launcher({
  image = theme.awesome_icon,
  menu = RC.mainmenu
})

menubar.utils.terminal = RC.vars.terminal

RC.globalkeys = keybinds.globalkeys()
RC.globalkeys = keybinds.bindtotags(RC.globalkeys)
RC.mediakeys =  keybinds.mediakeys()

-- Set root
root.buttons(keybinds.globalbuttons())
root.keys(
  gears.table.join(RC.globalkeys, RC.mediakeys)
)

-- Rules to apply to new clients (through the "manage" signal).
awful.rules.rules = main.rules(
  keybinds.clientkeys(),
  keybinds.clientbuttons()
)

require("statusbar") -- Load statusbar
-- require("main.autostart") -- Autostart

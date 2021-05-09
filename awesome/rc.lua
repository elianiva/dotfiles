-- If LuaRocks is installed, make sure that packages installed through it are
-- found (e.g. lgi). If LuaRocks is not installed, do nothing.
pcall(require, "luarocks.loader")
local gears = require("gears")
local awful = require("awful")
local beautiful = require("beautiful")
local menubar = require("menubar")

require("awful.autofocus") -- autofocus window
require("main.error-handling") -- error handling

-- Themes define colours, icons, font and wallpapers.
beautiful.init(os.getenv("HOME") .. "/.config/awesome/themes/main/theme.lua")

RC = {} -- global namespace
RC.vars = require("main.variables") -- user defined variables

local main = {
  rules = require("main.rules"), -- define rules
  signals = require("main.signals"), -- define signals
  titlebar = require("main.titlebar"), -- titlebar
  volume = require("main.volume-widget"), -- volume widget
}

main.signals()
main.titlebar()
main.volume()

local keybinds = {
  clientbuttons = require("keybinds.clientbuttons"),
  globalkeys = require("keybinds.globalkeys"),
  bindtotags = require("keybinds.bindtotags"),
  clientkeys = require("keybinds.clientkeys"),
  mediakeys = require("keybinds.mediakeys"),
}

RC.layouts = require("main.layouts")
RC.tags = require("main.tags")

menubar.utils.terminal = RC.vars.terminal

RC.globalkeys = keybinds.bindtotags(keybinds.globalkeys)
RC.mediakeys = keybinds.mediakeys

-- Set root
root.keys(gears.table.join(RC.globalkeys, RC.mediakeys))

-- Rules to apply to new clients (through the "manage" signal).
awful.rules.rules = main.rules(keybinds.clientkeys, keybinds.clientbuttons)

require("statusbar") -- Load statusbar
require("main.autostart") -- Autostart

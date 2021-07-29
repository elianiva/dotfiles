-- If LuaRocks is installed, make sure that packages installed through it are
-- found (e.g. lgi). If LuaRocks is not installed, do nothing.
pcall(require, "luarocks.loader")
require("beautiful").init(
  os.getenv "HOME" .. "/.config/awesome/themes/main/theme.lua"
)
require "awful.autofocus"

local gears = require "gears"
local menubar = require "menubar"
local bind_to_tags = require "keybinds.bindtotags"
local mediakeys = require "keybinds.mediakeys"
local globalkeys = require "keybinds.globalkeys"

local terminal = require("main.variables").terminal
menubar.utils.terminal = terminal

root.keys(gears.table.join(bind_to_tags(globalkeys), mediakeys))

require("main.error-handling").setup()
require("main.signals").setup()
require("main.titlebar").setup()
require("main.volume-widget").setup()
require("main.tags").setup()
require("main.autostart").setup()
require("main.rules").setup()
require("statusbar").setup()

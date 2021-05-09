local gears = require("gears")
local awful = require("awful")
local naughty = require("naughty")
local exit_screen_show = require("main.exitscreen")
local systray = require("statusbar.modules.systray")

-- Resource Configuration
local launcher = RC.vars.launcher
local shot = RC.vars.shot
local emoji_picker = RC.vars.emoji_picker
local clipmenu = RC.vars.clipmenu
local terminal = RC.vars.terminal
local modkey = RC.vars.modkey

local M = gears.table.join(
  awful.key({ modkey }, "s", function()
    awful.hotkeys_popup.show_help(nil, awful.screen.focused())
  end,
  {description="show help", group="awesome"}),

  -- Toggle tray visibility
  awful.key({ modkey }, "=", function()
    systray.visible = not systray.visible
  end,
  {description = "toggle tray visibility", group = "awesome"}),

  -- Tag browsing
  awful.key({ modkey }, "Left", function()
    awful.tag.viewprev()
  end,
  {description = "view previous", group = "tag"}),

  awful.key({ modkey, }, "Right", function()
    awful.tag.viewnext()
  end,
  {description = "view next", group = "tag"}),

  awful.key({ modkey }, "Tab", function()
    awful.tag.history.restore()
  end,
  {description = "go back", group = "tag"}),

  -- Standard program
  awful.key({ modkey }, "Return", function()
    awful.spawn(terminal)
  end,
  {description = "open a terminal", group = "launcher"}),

  awful.key({ modkey }, "d", function()
    awful.spawn.with_shell(launcher .. "run " .. theme.color_name)
  end,
  {description = "open app launcher", group = "launcher"}),

  awful.key({ modkey, "Shift" }, "d", function()
    awful.spawn.with_shell(launcher .. "run " .. theme.color_name)
  end,
  {description = "open command launcher", group = "launcher"}),

  awful.key({ modkey, "Shift" }, "x", function()
    exit_screen_show()
  end,
  {description = "show exit screen", group = "awesome"}),

  awful.key({ modkey }, "e", function()
    awful.spawn(emoji_picker)
  end,
  {description = "pick an emoji", group = "launcher"}),

  awful.key({ modkey }, "c", function()
    awful.spawn(clipmenu)
  end,
  {description = "launch clipmenu", group = "launcher"}),

  awful.key({ modkey, "Shift"   }, "r", function()
    awesome.restart()
  end,
  {description = "reload awesome", group = "awesome"}),

  awful.key({ modkey, "Shift"   }, "q", function()
    awesome.quit()
  end,
  {description = "quit awesome", group = "awesome"}),

  awful.key({ modkey }, "t", function()
    awful.layout.set(awful.layout.suit.tile)
  end,
  {description = "set to tiling mode", group = "layout"}),

  awful.key({ modkey }, "`", function()
    naughty.destroy_all_notifications()
  end,
  {description = "dismiss notification", group = "notifications"}),

  awful.key({ modkey }, "Print", function()
    awful.spawn.with_shell(shot)
  end,
  {description = "screenshot with borders", group = "misc"}),

  awful.key({ }, "Print", function()
    awful.spawn.with_shell("flameshot gui -p "..os.getenv("HOME").."/pix/shots")
  end,
  {description = "screenshot without borders", group = "misc"})
)

return M

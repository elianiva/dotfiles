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

  awful.key({ modkey }, "h", function()
    awful.client.focus.bydirection("left")
  end,
  {description = "focus to left window ", group = "layout"}),

  awful.key({ modkey }, "j", function()
    awful.client.focus.bydirection("down")
  end,
  {description = "focus to window below ", group = "client"}),

  awful.key({ modkey }, "k", function()
    awful.client.focus.bydirection("up")
  end,
  {description = "focus to window above", group = "client"}),

  awful.key({ modkey }, "l", function()
    awful.client.focus.bydirection("right")
  end,
  {description = "focus to right window", group = "layout"}),

  -- Layout manipulation
  awful.key({ modkey, "Shift"   }, "j", function()
    awful.client.swap.bydirection("down")
  end,
  {description = "swap with next client by index", group = "client"}),

  awful.key({ modkey, "Shift"   }, "k", function()
    awful.client.swap.bydirection("up")
  end,
  {description = "swap with previous client by index", group = "client"}),

  awful.key({ modkey, "Shift"   }, "h", function()
    awful.client.swap.bydirection("left")
  end,
  {description = "swap with right", group = "layout"}),

  awful.key({ modkey, "Shift"   }, "l", function()
    awful.client.swap.bydirection("right")
  end,
  {description = "swap with left", group = "layout"}),

  awful.key({ modkey }, "u", function()
    awful.client.urgent.jumpto()
  end,
  {description = "jump to urgent client", group = "client"}),

  -- Standard program
  awful.key({ modkey }, "Return", function()
    awful.spawn(terminal)
  end,
  {description = "open a terminal", group = "launcher"}),

  awful.key({ modkey }, "d", function()
    awful.spawn.with_shell(launcher .. "drun " .. theme.color_name)
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

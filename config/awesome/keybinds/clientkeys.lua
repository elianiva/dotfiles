-- Standard Awesome library
local gears = require("gears")
local awful = require("awful")
local beautiful = require("beautiful")
local helpers = require("main.helpers")
local vars = require "main.variables"

local modkey = vars.modkey
local ctrlkey = vars.ctrlkey
local altkey = vars.altkey

local clientkeys = gears.table.join(
  awful.key({ modkey }, "0", function(c)
    c.fullscreen = not c.fullscreen
    c:raise()
  end,
  {description = "toggle fullscreen", group = "client"}),

  awful.key({ modkey }, "q", function(c)
    c:kill()
  end,
  {description = "close", group = "client"}),

  awful.key({ modkey }, "f", function(c)
    awful.client.floating.toggle(c)
  end,
  {description = "toggle floating", group = "client"}),

  awful.key({ modkey,  }, "g", function(c)
    c:swap(awful.client.getmaster())
  end,
  {description = "move to master", group = "client"}),

  awful.key({ modkey }, "o", function(c)
    c:move_to_screen()
  end,
  {description = "move to screen", group = "client"}),

  awful.key({ modkey }, "m", function(c)
    c.maximized = not c.maximized
    if c.maximized == true then
      c.border_width = "0"
      c.border_color = beautiful.border_focus
    else
      c.border_width = beautiful.border_width
      c.border_color = beautiful.border_focus
    end
    c:raise()
  end ,
  {description = "(un)maximize", group = "client"}),

  awful.key({ modkey, "Control" }, "m", function(c)
    c.maximized_vertical = not c.maximized_vertical
    c:raise()
  end ,
  {description = "(un)maximize vertically", group = "client"}),

  awful.key({ modkey, "Shift" }, "m", function(c)
    c.maximized_horizontal = not c.maximized_horizontal
    c:raise()
  end ,
  {description = "(un)maximize horizontally", group = "client"}),

  -- Resize
  awful.key({ modkey, "Shift" }, "j", function()
    awful.client.moveresize( 0, 0, 0, 20)
  end,
  {description = "increase window height", group = "client"}),

  awful.key({ modkey, "Shift" }, "k", function()
    awful.client.moveresize( 0, 0, 0,  -20)
  end,
  {description = "decrease window height", group = "client"}),

  awful.key({ modkey, "Shift" }, "h", function()
    awful.client.moveresize( 0, 0, -20, 0)
  end,
  {description = "decrease window width", group = "client"}),

  awful.key({ modkey, "Shift" }, "l", function()
    awful.client.moveresize( 0, 0,  20, 0)
  end,
  {description = "increase window width", group = "client"}),

  -- Cycle through window
  awful.key({ altkey }, "Tab", function()
    awful.client.focus.byidx(1)
  end,
  {description = "cycle through window", group = "client"}),

  awful.key({ altkey, "Shift" }, "Tab", function()
    awful.client.focus.byidx(-1)
  end,
  {description = "cycle through window in reverse", group = "client"}),

  -- Resize window
  awful.key({ modkey, ctrlkey }, "j", function()
    helpers.resize_dwim(client.focus, "down")
  end,
  {description = "make window bigger to bottom", group = "client"}),

  awful.key({ modkey, ctrlkey }, "k", function()
    helpers.resize_dwim(client.focus, "up")
  end,
  {description = "make window bigger to top", group = "client"}),

  awful.key({ modkey, ctrlkey }, "h", function()
    helpers.resize_dwim(client.focus, "left")
  end,
  {description = "make window bigger to left", group = "client"}),

  awful.key({ modkey, ctrlkey }, "l", function()
    helpers.resize_dwim(client.focus, "right")
  end,
  {description = "make window bigger to right", group = "client"}),

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
  {description = "jump to urgent client", group = "client"})
)

return clientkeys

-- Standard Awesome library
local gears = require("gears")
local awful = require("awful")
local beautiful = require("beautiful")
local helpers = require("main.helpers")
-- Custom Local Library
-- local titlebar = require("anybox.titlebar")

local _M = {}
local modkey = RC.vars.modkey
local ctrlkey = RC.vars.ctrlkey

function _M.get()
  local clientkeys = gears.table.join(
    awful.key({ modkey, }, "0",
        function (c)
            c.fullscreen = not c.fullscreen
            c:raise()
        end,
        {description = "toggle fullscreen", group = "client"}
    ),

    awful.key({ modkey, }, "q",
        function (c) c:kill() end,
        {description = "close", group = "client"}
    ),

    awful.key({ modkey, }, "f",
        awful.client.floating.toggle,
        {description = "toggle floating", group = "client"}
    ),

    awful.key({ modkey,  }, "g",
        function (c) c:swap(awful.client.getmaster()) end,
        {description = "move to master", group = "client"}
    ),

    awful.key({ modkey, }, "o",
        function (c) c:move_to_screen() end,
        {description = "move to screen", group = "client"}
    ),

    awful.key({ modkey, }, "m",
        function (c)
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
        {description = "(un)maximize", group = "client"}
    ),

    awful.key({ modkey, "Control" }, "m",
        function (c)
            c.maximized_vertical = not c.maximized_vertical
            c:raise()
        end ,
        {description = "(un)maximize vertically", group = "client"}
    ),

    awful.key({ modkey, "Shift"   }, "m",
        function (c)
            c.maximized_horizontal = not c.maximized_horizontal
            c:raise()
        end ,
        {description = "(un)maximize horizontally", group = "client"}
    ),

    -- Resize
    awful.key({ modkey, "Shift" }, "j",
        function () awful.client.moveresize( 0, 0, 0, 20) end,
        {description = "increase window height", group = "client"}
    ),

    awful.key({ modkey, "Shift" }, "k",
        function () awful.client.moveresize( 0, 0, 0,  -20) end,
        {description = "decrease window height", group = "client"}
    ),

    awful.key({ modkey, "Shift" }, "h",
        function () awful.client.moveresize( 0, 0, -20, 0) end,
        {description = "decrease window width", group = "client"}
    ),

    awful.key({ modkey, "Shift" }, "l",
        function () awful.client.moveresize( 0, 0,  20, 0) end,
        {description = "increase window width", group = "client"}
    ),

    -- Cycle through window
    awful.key({ altkey, }, "Tab",
        function ()
            awful.client.focus.byidx(1)
        end,
        {description = "cycle through window", group = "client"}
    ),

    awful.key({ altkey, "Shift" }, "Tab",
        function ()
            awful.client.focus.byidx(-1)
        end,
        {description = "cycle through window in reverse", group = "client"}
    ),

    -- Resize window
    awful.key({ modkey, ctrlkey }, "j", function (c)
        helpers.resize_dwim(client.focus, "down")
    end),
    awful.key({ modkey, ctrlkey }, "k", function (c)
        helpers.resize_dwim(client.focus, "up")
    end),
    awful.key({ modkey, ctrlkey }, "h", function (c)
        helpers.resize_dwim(client.focus, "left")
    end),
    awful.key({ modkey, ctrlkey }, "l", function (c)
        helpers.resize_dwim(client.focus, "right")
    end)

)

  return clientkeys
end

return setmetatable({}, { __call = function(_, ...) return _M.get(...) end })

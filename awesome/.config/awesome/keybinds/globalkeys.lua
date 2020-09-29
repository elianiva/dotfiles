local gears = require("gears")
local awful = require("awful")
local naughty = require("naughty")
local hotkeys_popup = require("awful.hotkeys_popup")
local menubar = require("menubar")

-- Resource Configuration
local launcher = RC.vars.launcher
local powermenu = RC.vars.powermenu
local shot = RC.vars.shot
local emoji_picker = RC.vars.emoji_picker
local clipmenu = RC.vars.clipmenu

local _M = {}

function _M.get()
  local globalkeys = gears.table.join(

    awful.key({ modkey }, "s",
        hotkeys_popup.show_help,
        {description="show help", group="awesome"}
    ),

    -- Toggle tray visibility
    awful.key({ modkey }, "=",
        function ()
            systray.visible = not systray.visible
        end,
        {description = "toggle tray visibility", group = "awesome"}),

    -- Tag browsing
    awful.key({ modkey, }, "Left",
        awful.tag.viewprev,
        {description = "view previous", group = "tag"}
    ),

    awful.key({ modkey, }, "Right",
        awful.tag.viewnext,
        {description = "view next", group = "tag"}
    ),

    awful.key({ modkey, }, "Escape",
        awful.tag.history.restore,
        {description = "go back", group = "tag"}
    ),

    awful.key({ modkey, }, "h",
        function () awful.client.focus.bydirection("left") end,
        {description = "focus to left window ", group = "layout"}
    ),

    awful.key({ modkey, }, "j",
        function () awful.client.focus.bydirection("down") end,
        {description = "focus to window below ", group = "client"}
    ),

    awful.key({ modkey, }, "k",
        function () awful.client.focus.bydirection("up") end,
        {description = "focus to window above", group = "client"}
    ),

    awful.key({ modkey, }, "l",
        function () awful.client.focus.bydirection("right") end,
        {description = "focus to right window", group = "layout"}
    ),

    -- Layout manipulation
    awful.key({ modkey, "Shift"   }, "j",
        function () awful.client.swap.bydirection("down") end,
        {description = "swap with next client by index", group = "client"}
    ),

    awful.key({ modkey, "Shift"   }, "k",
        function () awful.client.swap.bydirection("up")    end,
        {description = "swap with previous client by index", group = "client"}
    ),

    awful.key({ modkey, "Shift"   }, "h",
        function () awful.client.swap.bydirection("left") end,
        {description = "swap with right", group = "layout"}
    ),

    awful.key({ modkey, "Shift"   }, "l",
        function () awful.client.swap.bydirection("right") end,
        {description = "swap with left", group = "layout"}
    ),

    awful.key({ modkey, }, "u",
        awful.client.urgent.jumpto,
        {description = "jump to urgent client", group = "client"}
    ),

    -- Standard program
    awful.key({ modkey, }, "Return",
        function () awful.spawn(terminal) end,
        {description = "open a terminal", group = "launcher"}
    ),

    awful.key({ modkey, }, "d",
        function () awful.spawn.with_shell(launcher .. "drun") end,
        {description = "open app launcher", group = "launcher"}
    ),

    awful.key({ modkey, "Shift"   }, "d",
        function () awful.spawn.with_shell(launcher .. "run") end,
        {description = "open command launcher", group = "launcher"}
    ),

    -- awful.key({ modkey, }, "x",
    --     function () awful.spawn.with_shell(powermenu .. "drun") end,
    --     {description = "open powermenu", group = "launcher"}
    -- ),

    awful.key({ modkey, }, "x",
        function() exit_screen_show() end,
        {description = "show exit screen", group = "awesome"}
    ),

    awful.key({ modkey, }, "e",
        function () awful.spawn(emoji_picker) end,
        {description = "pick an emoji", group = "launcher"}
    ),

    awful.key({ modkey, }, "c",
        function () awful.spawn(clipmenu) end,
        {description = "launch clipmenu", group = "launcher"}
    ),

    awful.key({ modkey, "Shift"   }, "r",
        awesome.restart,
        {description = "reload awesome", group = "awesome"}
    ),

    awful.key({ modkey, "Shift"   }, "q",
        awesome.quit,
        {description = "quit awesome", group = "awesome"}
    ),

    awful.key({ modkey, }, "t",
        function()  awful.layout.set(awful.layout.suit.tile) end,
        {description = "set to tiling mode", group = "layout"}
    ),


    -- Dismiss notifications
    awful.key({ ctrlkey }, "space",
        function()
            naughty.destroy_all_notifications()
        end,
        {description = "dismiss notification", group = "notifications"}
    ),

    -- Menubar
    -- awful.key({ modkey }, "p", function() menubar.show() end,
              -- {description = "show the menubar", group = "launcher"}),

    -- Screenshot
    awful.key({ modkey }, "Print", function() awful.spawn.with_shell(shot) end,
              {description = "screenshot edited", group = "misc"}),
    awful.key({ }, "Print", function() awful.spawn.with_shell("flameshot gui -p ~/pix/shots") end,
              {description = "screenshot no edit", group = "misc"})
  )

  return globalkeys
end

return setmetatable({}, { __call = function(_, ...) return _M.get(...) end })

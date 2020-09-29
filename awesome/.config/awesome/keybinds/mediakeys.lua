local gears = require("gears")
local awful = require("awful")

local _M = {}

function _M.get()
  local globalkeys = gears.table.join(
    awful.key({}, "XF86AudioLowerVolume",
        function()
            awesome.emit_signal("volume_change")
            awful.spawn("pulsemixer --change-volume -2", false)
        end,
        {description = "lower the volume", group = "media"}
    ),
    awful.key({}, "XF86AudioRaiseVolume",
        function()
            awesome.emit_signal("volume_change")
            awful.spawn("pulsemixer --change-volume +2", false)
        end,
        {description = "raise the volume", group = "media"}
    ),
    awful.key({}, "XF86AudioMute",
        function() awful.spawn("pulsemixer --toggle-mute", false) end,
        {description = "mute the audio", group = "media"}
    ),

    awful.key({}, "XF86AudioPlay",
        function() awful.spawn.with_shell("playerctl --player=%any,chromium play-pause") end,
        {description = "toggle the audio", group = "media"}
    ),

    awful.key({}, "XF86AudioNext",
        function() awful.spawn.with_shell("playerctl --player=%any,chromium next") end,
        {description = "toggle the audio", group = "media"}
    ),

    awful.key({}, "XF86AudioPrev",
        function() awful.spawn.with_shell("playerctl --player=%any,chromium previous") end,
        {description = "toggle the audio", group = "media"}
    ),

    -- Brightness
    awful.key( { }, "XF86MonBrightnessDown",
        function() awful.spawn.with_shell("light -U 10") end,
        {description = "decrease brightness", group = "brightness"}
    ),

    awful.key( { }, "XF86MonBrightnessUp",
        function() awful.spawn.with_shell("light -A 10") end,
        {description = "increase brightness", group = "brightness"}
    )

  )

  return globalkeys
end

return setmetatable({}, { __call = function(_, ...) return _M.get(...) end })

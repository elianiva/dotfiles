local wibox = require("wibox")
local lgi = require("lgi")
local markup = require("lain").util.markup

local Playerctl = lgi.Playerctl
-- local player = Playerctl.Player.new_from_name(Playerctl.PlayerName{ name = "spotify" })
local player = Playerctl.Player{}
spotifyicon = wibox.widget.imagebox(
    colorize(theme.spotify, theme.widget_main_color)
)

playerctl_widget = wibox.widget.textbox()

update_metadata = function()
    if player:get_title() then
        playerctl_widget:set_markup(markup(theme.foreground, player:get_artist() .. " – " .. player:get_title()))
    else
        playerctl_widget:set_text('')
    end
end

player.on_metadata = update_metadata

playerctl_widget:connect_signal("button::press", function() player:play_pause() end)

update_metadata()

-- return gears.debug.dump_return(Playerctl.PlayerManager.props.player_names)
-- return gears.debug.dump_return(Playerctl)

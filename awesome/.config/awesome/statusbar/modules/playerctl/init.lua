local wibox = require("wibox")
local lgi = require("lgi")
local markup = require("lain").util.markup

local icon = os.getenv("HOME") .. "/.config/awesome/statusbar/modules/playerctl/icon.svg"

local Playerctl = lgi.Playerctl
local player = Playerctl.Player{}

local colorize = require("main.helpers").colorize

local M = {}

M.icon = wibox.widget.imagebox(
  colorize(icon, theme.widget_main_color)
)

M.widget = wibox.widget.textbox()

local update_metadata = function()
  if player:get_title() then
    M.widget:set_markup(markup(theme.foreground, player:get_artist() .. " – " .. player:get_title()))
  else
    M.widget:set_text('')
  end
end

player.on_metadata = update_metadata

M.widget:connect_signal("button::press", function() player:play_pause() end)

update_metadata()

return M

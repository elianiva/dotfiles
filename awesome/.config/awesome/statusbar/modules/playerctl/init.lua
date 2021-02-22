local wibox = require("wibox")
local gears = require("gears")
local awful = require("awful")
local colorize = require"main.helpers".colorize
local icon = os.getenv("HOME") .. "/.config/awesome/statusbar/modules/playerctl/icon.svg"

local M = {}

M.icon = wibox.widget.imagebox(colorize(icon, theme.widget_main_color))
M.widget = wibox.widget.textbox()

awful.spawn.with_line_callback(
  "playerctl --player=%any,chrome,chromium --follow metadata --format '{{artist}} - {{title}}'",
  {
    stdout = function (line)
      M.widget:set_markup(line, { fg = theme.foreground })
    end
  }
)

M.widget:buttons(gears.table.join(
  awful.button({}, 1, function()
    awful.spawn.easy_async("playerctl --player=%any,chrome,chromium play-pause")
  end)
))

return M

local wibox = require("wibox")
local lain = require("lain")
local markup = lain.util.markup
local icon = os.getenv("HOME") .. "/.config/awesome/statusbar/modules/cpu/icon.svg"
local colorize = require("main.helpers").colorize

local M = {}

-- CPU
M.icon = wibox.widget.imagebox(
  colorize(icon, theme.widget_main_color)
)

M.widget = lain.widget.cpu({
  timeout = 2,
  settings = function()
    widget:set_markup(markup(theme.foreground, cpu_now.usage .. "%"))
  end
}).widget -- call the actual lain widget

return M

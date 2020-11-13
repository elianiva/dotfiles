local wibox = require("wibox")
local lain = require("lain")
local markup = lain.util.markup
local icon = os.getenv("HOME") .. "/.config/awesome/statusbar/modules/memory/icon.svg"
local colorize = require("main.helpers").colorize

local M = {}

-- Memory
M.icon = wibox.widget.imagebox(colorize(icon, theme.widget_main_color))

M.widget = lain.widget.mem({
  timeout = 2,
  settings = function()
    widget:set_markup(markup(theme.foreground, mem_now.perc .. "%"))
  end
}).widget -- call the actual lain widget

return M

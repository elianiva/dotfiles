local wibox = require("wibox")
local dpi = require('beautiful').xresources.apply_dpi

local M = {}

-- this needs to be global
M.widget = wibox.widget.systray({forced_height = dpi(28)})

M.widget:set_base_size(dpi(20))

return M

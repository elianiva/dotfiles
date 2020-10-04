local wibox = require("wibox")
local dpi = require('beautiful').xresources.apply_dpi

local M = {}

function M.get()
  systray = wibox.widget.systray({
    forced_height = dpi(28)
  })
  systray:set_base_size(dpi(20))

  return systray
end

return setmetatable({}, { __call = function(_, ...) return M.get(...) end })

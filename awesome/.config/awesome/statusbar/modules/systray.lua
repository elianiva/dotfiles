local wibox = require("wibox")
local dpi = require('beautiful').xresources.apply_dpi

systray = wibox.widget.systray({
  forced_height = dpi(28)
})
systray:set_base_size(dpi(20))

return systray

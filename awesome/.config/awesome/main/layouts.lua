local awful = require("awful")

local M = {}

function M.get()
  -- Table of layouts to cover with awful.layout.inc, order matters.
  local layouts = {
    awful.layout.suit.tile,
    awful.layout.suit.floating,
    awful.layout.suit.max,
 }

  return layouts
end

return setmetatable({}, { __call = function(_, ...) return M.get(...) end })

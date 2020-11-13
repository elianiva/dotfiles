local awful = require("awful")

local M = {}

-- Table of layouts to cover with awful.layout.inc, order matters.
M.layouts = {
  awful.layout.suit.tile,
  awful.layout.suit.floating,
  awful.layout.suit.max,
}

return M

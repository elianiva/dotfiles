local wezterm = require 'wezterm'
local config = wezterm.config_builder()
local mux = wezterm.mux

wezterm.on("gui-startup", function()
  local _, _, window = mux.spawn_window{}
  window:gui_window():maximize()
end)

config.font = wezterm.font "JetBrains Mono"
config.font_size = 12.5
config.line_height = 1.3
config.color_scheme = 'Vs Code Dark+ (Gogh)'

config.enable_wayland = true
config.front_end = "WebGpu"

-- spawn zellij as the default shell
config.default_prog = { 'zellij'  }

config.enable_tab_bar = false
config.window_decorations = "TITLE | RESIZE"

local padding = 4
config.window_padding = {
  top = padding,
  left = padding,
  right = padding,
  bottom = padding,
}

return config

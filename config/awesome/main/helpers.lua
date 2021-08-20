local awful = require "awful"
local gears = require "gears"
local wibox = require "wibox"
local xresources = require "beautiful.xresources"
local dpi = xresources.apply_dpi

local helpers = {}

helpers.noop = function()
end

-- Resize client or factor
local floating_resize_amount = dpi(20)
local tiling_resize_factor = 0.05

helpers.resize_dwim = function(c, direction)
  if c and c.floating then
    if direction == "up" then
      c:relative_move(0, 0, 0, -floating_resize_amount)
    elseif direction == "down" then
      c:relative_move(0, 0, 0, floating_resize_amount)
    elseif direction == "left" then
      c:relative_move(0, 0, -floating_resize_amount, 0)
    elseif direction == "right" then
      c:relative_move(0, 0, floating_resize_amount, 0)
    end
  elseif awful.layout.get(mouse.screen) ~= awful.layout.suit.floating then
    if direction == "up" then
      awful.client.incwfact(-tiling_resize_factor)
    elseif direction == "down" then
      awful.client.incwfact(tiling_resize_factor)
    elseif direction == "left" then
      awful.tag.incmwfact(-tiling_resize_factor)
    elseif direction == "right" then
      awful.tag.incmwfact(tiling_resize_factor)
    end
  end
end

helpers.colorize = function(icon, color)
  return gears.color.recolor_image(icon, color)
end

helpers.markup = function(content, opts)
  local fg = opts.fg or ""
  return string.format('<span foreground="%s">%s</span>', fg, content)
end

helpers.rrect = function(radius)
  return function(cr, width, height)
    gears.shape.rounded_rect(cr, width, height, radius)
  end
end

helpers.module_wrapper = function(opts)
  local left, right, top, bottom

  if opts.type == "icon" then
    left = opts.left or 6
    right = opts.right or 4
    top = opts.top or opts.no_bg and 8 or 4
    bottom = opts.bottom or opts.no_bg and 8 or 4
  elseif opts.type == "module" then
    left = opts.left or 0
    right = opts.right or 6
    top = opts.top or 4
    bottom = opts.bottom or 4
  end

  if opts.no_bg then
    return wibox.widget {
      opts.widget,
      top = dpi(top),
      left = dpi(left),
      right = dpi(right),
      bottom = dpi(bottom),
      widget = wibox.container.margin,
    }
  end

  return wibox.widget {
    {
      {
        {
          opts.widget,
          top = dpi(top),
          left = dpi(left),
          right = dpi(right),
          bottom = dpi(bottom),
          widget = wibox.container.margin,
        },
        bg = theme.grey_alt,
        widget = wibox.container.background,
      },
      color = theme.blue,
      bottom = dpi(1),
      widget = wibox.container.margin,
    },
    top = dpi(4),
    bottom = dpi(2),
    widget = wibox.container.margin,
  }
end

return helpers

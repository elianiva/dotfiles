local awful = require("awful")
local gears = require("gears")
local wibox = require("wibox")
local dpi = require"beautiful.xresources".apply_dpi
local margin = wibox.container.margin

local M = {}

function M.get()
  local function create_title_button(c, color_focus, color_unfocus)
    local tb_color = wibox.widget {
      bg = color_focus,
      widget = wibox.container.background,
      shape = gears.shape.circle,
    }

    local tb = wibox.widget {
      tb_color,
      width = dpi(12),
      height = dpi(12),
      strategy = "min",
      layout = wibox.container.constraint
    }

    local function update()
      if client.focus == c then
        tb_color.bg = color_focus
      else
        tb_color.bg = color_unfocus
      end
    end

    update()
    c:connect_signal("focus", update)
    c:connect_signal("unfocus", update)

    return tb
  end

  -- Add a titlebar if titlebars_enabled is set to true in the rules.
  client.connect_signal("request::titlebars", function(c)
      -- buttons for the titlebar
      local buttons = gears.table.join(
        awful.button({ }, 1, function()
          client.focus = c
          c:raise()
          awful.mouse.client.move(c)
        end),

        awful.button({ }, 3, function()
          c:emit_signal("request::activate", "titlebar", {raise = true})
          awful.mouse.client.resize(c)
        end)
      )

      local close = create_title_button(c, theme.red, theme.grey)
      close:connect_signal("button::press", function() c:kill() end)

      local floating = create_title_button(c, theme.yellow, theme.grey)
      floating:connect_signal("button::press", function()
        c.floating = not c.floating
      end)

      local fullscreen = create_title_button(c, theme.green, theme.grey)
      fullscreen:connect_signal("button::press", function()
        -- do nothing, this is for decoration
      end)

      local window_title = { -- client name
        align  = 'center',
        font   = theme.font,
        widget = awful.titlebar.widget.titlewidget(c)
      }

      local icon = { -- client icon
        widget = awful.titlebar.widget.iconwidget(c)
      }

      -- awful.titlebar(c, { position = "left", size = theme.titlebar_size}):setup {
      --   { close, layout = wibox.layout.fixed.vertical }, -- top left
      --   { buttons = buttons, layout  = wibox.layout.flex.vertical }, -- middle left
      --   { floating, layout = wibox.layout.fixed.vertical }, -- bottom left
      --   layout = wibox.layout.align.vertical
      -- }

      -- awful.titlebar(c, {position = "right", size = theme.titlebar_size}):setup {
      --   { close, layout  = wibox.layout.fixed.vertical }, -- top right
      --   { buttons = buttons, layout  = wibox.layout.flex.vertical }, -- middle right
      --   { floating, layout = wibox.layout.fixed.vertical }, -- bottom right
      --   layout = wibox.layout.align.vertical
      -- }

      -- awful.titlebar(c, {position = "bottom", size = theme.titlebar_size}):setup {
      --   { floating, layout  = wibox.layout.fixed.horizontal }, -- bottom left
      --   { buttons = buttons, layout  = wibox.layout.flex.horizontal }, -- middle
      --   { floating, layout = wibox.layout.fixed.horizontal }, -- bottom right
      --   layout = wibox.layout.align.horizontal
      -- }

      awful.titlebar(c, {position = "top", size = theme.titlebar_size}):setup {
        {
          margin(icon, dpi(2), dpi(2), dpi(2), dpi(2)),
          layout = wibox.layout.fixed.horizontal
        },
        { window_title, buttons = buttons, layout  = wibox.layout.flex.horizontal },
        {
          floating,
          fullscreen,
          margin(close, dpi(0), dpi(8)),
          spacing = dpi(8),
          layout = wibox.layout.fixed.horizontal
        },
        layout = wibox.layout.align.horizontal
      }
    end
  )
end

return setmetatable({}, { __call = function(_, ...) return M.get(...) end })

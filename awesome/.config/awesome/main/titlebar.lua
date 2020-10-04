local awful = require("awful")
local gears = require("gears")
local wibox = require("wibox")
local beautiful = require("beautiful")
local dpi = require("beautiful.xresources").apply_dpi

local M = {}

function M.get()
  local function create_title_button(c, color_focus, color_unfocus)
    local tb_color = wibox.widget {
      bg      = color_focus,
      widget  = wibox.container.background,
    }

    local tb = wibox.widget {
      tb_color,
      width    = dpi(20),
      height   = dpi(20),
      strategy = "min",
      layout   = wibox.container.constraint
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
  client.connect_signal("request::titlebars",
    function(c)
      -- buttons for the titlebar
      local buttons = gears.table.join(
        awful.button({ }, 1, function()
          c:emit_signal("request::activate", "titlebar", {raise = true})
          if c.maximized == true then
            c.maximized = false
          end
          awful.mouse.client.move(c)
        end),
        awful.button({ }, 3, function()
          c:emit_signal("request::activate", "titlebar", {raise = true})
          awful.mouse.client.resize(c)
        end)
      )

      local borderbuttons = gears.table.join(
        awful.button({ }, 3, function()
          c:emit_signal("request::activate", "titlebar", {raise = true})
          awful.mouse.client.resize(c)
        end),

        awful.button({ }, 1, function()
          c:emit_signal("request::activate", "titlebar", {raise = true})
          awful.mouse.client.resize(c)
        end)
      )

      local close = create_title_button(c, theme.widget_main_color, theme.black)
      close:connect_signal("button::press", function() c:kill() end)

      local floating = create_title_button(c, theme.widget_main_color, theme.black)
      floating:connect_signal("button::press", function() c.floating = not c.floating end)

      awful.titlebar(c, { position = "left", size = beautiful.titlebar_size}):setup {
        { floating, layout = wibox.layout.fixed.vertical }, -- left
        { buttons = buttons, layout  = wibox.layout.flex.vertical }, -- middle
        { close, layout = wibox.layout.fixed.vertical }, -- right
        layout = wibox.layout.align.vertical
      }

      awful.titlebar(c, {position = "right", size = beautiful.titlebar_size}):setup {
        { floating, layout  = wibox.layout.fixed.vertical }, -- left
        { buttons = buttons, layout  = wibox.layout.flex.vertical }, -- middle
        { close, layout = wibox.layout.fixed.vertical }, -- right
        layout = wibox.layout.align.vertical
      }

      awful.titlebar(c, {position = "bottom", size = beautiful.titlebar_size}):setup {
        { floating, layout  = wibox.layout.fixed.horizontal }, -- left
        { buttons = buttons, layout  = wibox.layout.flex.horizontal }, -- middle
        { close, layout = wibox.layout.fixed.horizontal }, -- right
        layout = wibox.layout.align.horizontal
      }

      awful.titlebar(c, {position = "top", size = beautiful.titlebar_size}):setup {
        { floating, layout  = wibox.layout.fixed.horizontal }, -- left
        { buttons = buttons, layout  = wibox.layout.flex.horizontal }, -- middle
        { close, layout = wibox.layout.fixed.horizontal }, -- right
        layout = wibox.layout.align.horizontal
      }
    end
  )
end

return setmetatable({}, { __call = function(_, ...) return M.get(...) end })

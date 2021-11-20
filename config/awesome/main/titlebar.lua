local awful = require("awful")
local gears = require("gears")
local wibox = require("wibox")
local dpi = require("beautiful.xresources").apply_dpi
local margin = wibox.container.margin

local M = {}

function M.setup()
	local create_title_button = function(c, color_focus, color_unfocus)
		local tb_color = wibox.widget({
			bg = theme.black,
			shape = gears.shape.circle,
			shape_border_width = dpi(5),
			shape_border_color = color_focus,
			widget = wibox.container.background,
		})

		local tb = wibox.widget({
			tb_color,
			width = dpi(12),
			height = dpi(12),
			strategy = "min",
			layout = wibox.container.constraint,
		})

		local update = function()
			if client.focus == c then
				tb_color.shape_border_color = color_focus
			else
				tb_color.shape_border_color = color_unfocus
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
			awful.button({}, 1, function()
				client.focus = c
				c:raise()
				awful.mouse.client.move(c)
			end),

			awful.button({}, 3, function()
				c:emit_signal("request::activate", "titlebar", { raise = true })
				awful.mouse.client.resize(c)
			end)
		)

		local close = create_title_button(c, theme.red, theme.grey)
		close:connect_signal("button::press", function()
			c:kill()
		end)

		local floating = create_title_button(c, theme.yellow, theme.grey)
		floating:connect_signal("button::press", function()
			c.ontop = not c.ontop
		end)

		local fullscreen = create_title_button(c, theme.green, theme.grey)
		fullscreen:connect_signal("button::press", function()
			c.floating = not c.floating
		end)

		local window_title = { -- client name
			align = "center",
			font = theme.titlebar_font,
			widget = awful.titlebar.widget.titlewidget(c),
		}

		local icon = { -- client icon
			widget = awful.titlebar.widget.iconwidget(c),
		}

		awful.titlebar(c, { position = "top", size = theme.titlebar_size }):setup({
			{
				margin(icon, dpi(2), dpi(2), dpi(2), dpi(2)),
				layout = wibox.layout.fixed.horizontal,
			},
			{
				window_title,
				buttons = buttons,
				layout = wibox.layout.flex.horizontal,
			},
			{
				floating,
				fullscreen,
				margin(close, dpi(0), dpi(8)),
				spacing = dpi(8),
				layout = wibox.layout.fixed.horizontal,
			},
			layout = wibox.layout.align.horizontal,
		})
	end)
end

return M

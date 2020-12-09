local naughty = require("naughty")
local wibox = require("wibox")
local dpi = require"beautiful.xresources".apply_dpi

naughty.config.padding = dpi(10)
naughty.config.icon_dirs = {
  "/usr/share/icons/Numix/32/apps/", "/usr/share/pixmaps/"
}
naughty.config.icon_formats = {"png", "svg"}
naughty.config.defaults.icon_size = theme.notification_icon_size
naughty.config.defaults.margin = theme.notification_margin
naughty.config.defaults.border_width = theme.notification_border_width
naughty.config.defaults.title = "System Notification"

naughty.connect_signal("request::display", function(notif)
  local action_widget = {
    base_layout = wibox.widget{
      spacing = dpi(4),
      layout = wibox.layout.fixed.horizontal
    },

    widget_template = {
      {
        {
          {
            {id = 'text_role', widget = wibox.widget.textbox},
            valign = "center",
            halign = "center",
            widget = wibox.container.place
          },
          left = dpi(8),
          right = dpi(8),
          widget = wibox.container.margin
        },
        shape_border_width = dpi(0),
        forced_height = dpi(28),
        bg = theme.grey_alt,
        widget = wibox.container.background
      },
      right = dpi(4),
      top = dpi(4),
      widget = wibox.container.margin
    },
    style = {underline_normal = false, underline_selected = false},
    widget = naughty.list.actions
  }

  naughty.layout.box{
    notification = notif,
    type = "notification",
    widget_template = {
      {
        {
          {
            {
              naughty.widget.icon,
              {
                {
                  font = theme.notification_font,
                  markup = "<b>" .. notif.title .. "</b>",
                  widget = wibox.widget.textbox
                },
                naughty.widget.message,
                action_widget,
                spacing = dpi(4),
                layout = wibox.layout.fixed.vertical
              },
              fill_space = true,
              spacing = dpi(8),
              layout = wibox.layout.fixed.horizontal
            },
            spacing = dpi(10),
            layout = wibox.layout.fixed.vertical
          },
          margins = dpi(8),
          widget = wibox.container.margin
        },
        id = "background_role",
        widget = naughty.container.background
      },
      strategy = "max",
      width = theme.notification_max_width or dpi(500),
      widget = wibox.container.constraint
    },
    bg = theme.black,
    border_color = theme.notification_border_color,
    border_width = theme.border_width,
    widget = wibox.container.background
  }
end)

local awful     = require("awful")
local beautiful = require("beautiful")

local M = {}

function M.get(clientkeys, clientbuttons)
  local rules = {
    -- All clients will match this rule.
    {
      rule = {},
      properties = {
        border_width = beautiful.border_width,
        border_color = beautiful.border_normal,
        focus = awful.client.focus.filter,
        raise = true,
        keys = clientkeys,
        buttons = clientbuttons,
        screen = awful.screen.preferred,
        titlebars_enabled = true
      }
    },

    -- Floating clients.
    {
      rule_any = {
        instance = {
        "pinentry"
        },
        class = {
          "Arandr",
          "Pcmanfm",
          "Sxiv",
          "connman-gtk",
          "Connman-gtk",
          "SimpleScreenRecorder",
          "Anki",
          "lxappearance",
          "Lxappearance",
          "fcitx5-config-qt",
          "jswing-App"
        },

        -- Note that the name property shown in xprop might be set slightly after creation of the client
        -- and the name shown there might not match defined rules here.
        name = {
          "Event Tester",  -- xev.
          "Open File",  -- file picker
          "Media viewer",  -- new telegram image viewer
        },
        role = {
          "GtkFileChooserDialog",  -- file picker
          "pop-up",       -- e.g. Google Chrome's (detached) Developer Tools.
        }
      },
      properties = {
        floating = true,
        placement = awful.placement.centered
      }
    },

    {
      rule_any = {
        name = {
          "Media viewer",  -- new telegram image viewer
        },
      },
      properties = {
        fullscreen = true,
        placement = awful.placement.centered
      }
    },

    -- Add titlebars to normal clients and dialogs
    {
      rule_any = {
        type = { "normal", "dialog" }
      },
      properties = {
        titlebars_enabled = true
      }
    },

    -- remove borders from browsers
    {
      rule_any = {
        class = {
          "Chromium",
          "Google-chrome-unstable",
          "firefoxdeveloperedition",
          "Brave-browser",
          "DesktopEditors",
        },
      },
      properties = {
        border_width = 0,
        titlebars_enabled = false
      }
    },
  }

  return rules
end

return setmetatable({}, { __call = function(_, ...) return M.get(...) end })

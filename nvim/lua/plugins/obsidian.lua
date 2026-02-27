return {
  "obsidian-nvim/obsidian.nvim",
  version = "*",
  ft = "markdown",
  ---@module 'obsidian'
  ---@type obsidian.config
  opts = {
    legacy_commands = false,
    workspaces = {
      {
        name = "personal-notes",
        path = "~/Development/personal/notes",
      },
    },
    templates = {
      folder = "Templates",
      date_format = "%Y-%m-%d",
      time_format = "%H:%M",
      substitutions = {
        yesterday = function()
          return os.date("%Y-%m-%d", os.time() - 86400)
        end,
        tomorrow = function()
          return os.date("%Y-%m-%d", os.time() + 86400)
        end,
      },
      -- Auto-put notes in right folders based on template
      customizations = {
        Article = {
          notes_subdir = "Articles",
        },
        Person = {
          notes_subdir = "People",
        },
        Music = {
          notes_subdir = "Music",
        },
        Inbox = {
          notes_subdir = "Inbox",
        },
      },
    },
    daily_notes = {
      folder = "Daily",
      date_format = "%Y-%m-%d-%A",
      template = "Daily.md",
    },
  },
  keys = {
    { "<leader>oo", "<cmd>Obsidian<cr>", desc = "Obsidian Picker" },
    { "<leader>oa", "<cmd>Obsidian new_from_template Article<cr>", desc = "New Article" },
    { "<leader>op", "<cmd>Obsidian new_from_template Person<cr>", desc = "New Person" },
    { "<leader>om", "<cmd>Obsidian new_from_template Music<cr>", desc = "New Music" },
    { "<leader>oi", "<cmd>Obsidian new_from_template Inbox<cr>", desc = "New Inbox Item" },
    { "<leader>od", "<cmd>Obsidian today<cr>", desc = "Today's Daily Note" },
    { "<leader>os", "<cmd>Obsidian search<cr>", desc = "Search Notes" },
    { "<leader>ol", "<cmd>Obsidian links<cr>", desc = "Show Links" },
    { "<leader>ob", "<cmd>Obsidian backlinks<cr>", desc = "Show Backlinks" },
  },
}

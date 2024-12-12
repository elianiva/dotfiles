-- unused for now
return {
  "yetone/avante.nvim",
  event = "VeryLazy",
  enabled = true,
  lazy = false,
  version = false,
  opts = {
    provider = "openai",
    -- claude = {
    --   endpoint = "https://api.anthropic.com",
    --   model = "claude-3-5-sonnet-20240620",
    --   api_key_name = "cmd:pass show elianiva/claude",
    --   temperature = 0,
    --   max_tokens = 4096,
    -- },
    openai = {
      endpoint = "https://api.deepseek.com",
      model = "deepseek-coder",
      api_key_name = "cmd:pass show elianiva/deepseek",
      temperature = 0,
      max_tokens = 4096,
    },
    behaviour = {
      auto_suggestions = false,
      auto_set_highlight_group = true,
      auto_set_keymaps = true,
      auto_apply_diff_after_generation = false,
      support_paste_from_clipboard = false,
    }
  },
  dependencies = {
    "nvim-treesitter/nvim-treesitter",
    "stevearc/dressing.nvim",
    "nvim-lua/plenary.nvim",
    "MunifTanjim/nui.nvim",
    --- The below dependencies are optional,
    "nvim-tree/nvim-web-devicons", -- or echasnovski/mini.icons
    {
      -- support for image pasting
      "HakonHarnes/img-clip.nvim",
      event = "VeryLazy",
      opts = {
        default = {
          embed_image_as_base64 = false,
          prompt_for_file_name = false,
          drag_and_drop = {
            insert_mode = true,
          },
          use_absolute_path = true,
        },
      },
    },
  },
}

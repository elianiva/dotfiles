return {
  'dmtrKovalenko/fff.nvim',
  build = function()
    -- this will download prebuild binary or try to use existing rustup toolchain to build from source
    -- (if you are using lazy you can use gb for rebuilding a plugin if needed)
    require("fff.download").download_or_build_binary()
  end,
  -- if you are using nixos
  -- build = "nix run .#release",
  opts = {
    prompt = '❯ ',
    title = 'FFF',
    layout = {
      height = 0.9,
      width = 0.9,
      prompt_position = 'top',
      preview_position = 'right',
      preview_size = 0.5,
      flex = {
        size = 120,
        wrap = 'top',
      },
      show_scrollbar = true,
    },
    preview = {
      enabled = true,
      wrap_lines = false,
    },
    keymaps = {
      close = '<Esc>',
      select = '<CR>',
      select_split = '<C-s>',
      select_vsplit = '<C-v>',
      select_tab = '<C-t>',
      move_up = { '<Up>', '<C-p>' },
      move_down = { '<Down>', '<C-n>' },
      preview_scroll_up = '<C-u>',
      preview_scroll_down = '<C-d>',
      toggle_select = '<Tab>',
      send_to_quickfix = '<C-q>',
    },
    hl = {
      border = 'SnacksBorder',
      matched = 'SnacksPickerMatch',
      title = 'SnacksPickerTitle',
      prompt = 'SnacksPickerPrompt',
      frecency = 'Number',
      debug = 'Comment',
      combo_header = 'Number',
      scrollbar = 'SnacksPickerBorder',
      directory_path = 'Comment',
      grep_line_number = 'Comment',
    },
    debug = {
      enabled = false,
      show_scores = false,
    },
  },
  -- No need to lazy-load with lazy.nvim.
  -- This plugin initializes itself lazily.
  lazy = false,
  keys = {
    {
      "<leader>f",
      function() require('fff').find_files() end,
      desc = 'FFFind files',
    },
    {
      "<leader>/",
      function() require('fff').live_grep() end,
      desc = 'LiFFFe grep',
    },
    {
      "<leader>cc",
      function() require('fff').live_grep({ query = vim.fn.expand("<cword>") }) end,
      desc = 'Search current word',
    },
  }
}

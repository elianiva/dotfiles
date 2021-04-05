-- Specifies python and node provider path to make startup faster
vim.g.python3_host_prog = "/usr/bin/python3"
vim.g.node_host_prog = os.getenv("HOME") .. "/.local/npm/bin/neovim-node-host"

-- svelte
vim.g.vim_svelte_plugin_has_init_indent = 0

-- disable git messenger default mappings
vim.g.git_messenger_no_default_mappings = true

-- highlight yanked text for 250ms
vim.cmd [[au TextYankPost * silent! lua vim.highlight.on_yank { timeout = 250, higroup = "OnYank" }]]

-- highlight bg according to hex/rgb/rgba text
vim.cmd [[packadd nvim-colorizer.lua]]
require("colorizer").setup {
  ["*"] = {
    css = true,
    css_fn = true,
    mode = "background",
  },
}

require("hop").setup{}

require('nvim-biscuits').setup {
  default_config = {
    max_length = 40,
    min_distance = 6,
    prefix_string = " // ",
    on_events = { "InsertLeave", "CursorHold" }
  }
}

-- -- indentline
-- vim.g.indent_char = "▏"
-- vim.g.indent_blankline_char = "▏"
-- vim.g.indent_blankline_show_end_of_line = false
-- vim.g.indent_blankline_filetype_exclude = {"help", "Nvimtree"}
-- vim.g.indent_blankline_buftype_exclude = {"terminal", "prompt"}
-- vim.g.indent_blankline_show_current_context = true
-- vim.g.indent_blankline_context_highlight = "Label"
-- vim.g.indent_blankline_context_patterns = {"class", "function", "method", "^if", "^while", "^for", "^object", "^table", "block"}
-- vim.g.indent_blankline_show_trailing_blankline_indent = false

require("neogit").setup{}

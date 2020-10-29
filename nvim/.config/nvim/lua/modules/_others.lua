local g = vim.g

-- Specifies python and node provider path to make startup faster
g.python3_host_prog = '/usr/bin/python3'
g.node_host_prog = os.getenv("HOME") .. '/.local/npm/bin/neovim-node-host'

-- gitlens(blamer) delay
g.blamer_delay = 250

-- time format for gitlens(blamer)
g.blamer_relative_time = 1

-- svelte
g.vim_svelte_plugin_has_init_indent = 0

-- lexima
g.lexima_accept_pum_with_enter = 1

vim.cmd("au TextYankPost * silent! lua vim.highlight.on_yank{ timeout = 250 }")

-- local theme = base16.theme_from_array({
--   "#151326"; "#211D35"; "#2C2941"; "#4B5573";
--   "#909AA0"; "#EAE9E4"; "#ff0000"; "#FAEADE";
--   "#E64557"; "#dfaf8f"; "#F2D749"; "#44D695";
--   "#6391F4"; "#8278F0"; "#dc8cc3"; "#18152C";
-- })

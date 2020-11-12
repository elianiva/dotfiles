-- Specifies python and node provider path to make startup faster
vim.g.python3_host_prog = '/usr/bin/python3'
vim.g.node_host_prog = os.getenv("HOME") .. '/.local/npm/bin/neovim-node-host'

-- gitlens(blamer) delay
vim.g.blamer_delay = 250

-- time format for gitlens(blamer)
vim.g.blamer_relative_time = 1

-- svelte
vim.g.vim_svelte_plugin_has_init_indent = 0

-- lexima
vim.g.lexima_accept_pum_with_enter = 1

-- highlight yanked text for 250ms
vim.cmd("au TextYankPost * silent! lua vim.highlight.on_yank{ timeout = 250 }")

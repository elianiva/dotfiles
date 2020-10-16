-- Specifies python and node provider path to make startup faster
vim.g.python3_host_prog = '/usr/bin/python3'
vim.g.node_host_prog = '/home/elianiva/.local/npm/bin/neovim-node-host'

-- gitlens(blamer) delay
vim.g.blamer_delay = 250

-- time format for gitlens(blamer)
vim.g.blamer_relative_time = 1

-- not sure what this does, might delete this later
vim.g.htl_all_templates = 1

-- vlang
vim.g.v_highlight_array_whitespace_error = 0
vim.g.v_highlight_chan_whitespace_error = 0
vim.g.v_highlight_space_tab_error = 0
vim.g.v_highlight_trailing_whitespace_error = 0
vim.g.v_highlight_function_calls = 1
vim.g.v_highlight_fields = 1

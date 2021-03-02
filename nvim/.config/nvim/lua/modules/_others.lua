-- Specifies python and node provider path to make startup faster
vim.g.python3_host_prog = "/usr/bin/python3"
vim.g.node_host_prog = os.getenv("HOME") .. "/.local/npm/bin/neovim-node-host"

-- svelte
vim.g.vim_svelte_plugin_has_init_indent = 0

-- disable git messenger default mappings
vim.g.git_messenger_no_default_mappings = true

-- highlight yanked text for 250ms
vim.cmd [[au TextYankPost * silent! lua vim.highlight.on_yank{ timeout = 250 }]]

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

Presence = require("presence"):setup({
    -- This config table shows all available config options with their default values
    auto_update       = true,                       -- Update activity based on autocmd events (if `false`, map or manually execute `:lua Presence:update()`)
    editing_text      = "Editing %s",               -- Editing format string (either string or function(filename, path): string)
    workspace_text    = "Working on %s",            -- Workspace format string (either string or function(project_name, path): string)
    neovim_image_text = "The One True Text Editor", -- Text displayed when hovered over the Neovim image
    main_image        = "neovim",                   -- Main image display (either "neovim" or "file")
    client_id         = "793271441293967371",       -- Use your own Discord application client id (not recommended)
    log_level         = nil,                        -- Log messages at or above this level (one of the following: "debug", "info", "warn", "error")
})

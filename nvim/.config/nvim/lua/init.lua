-- change cwd to current directory
vim.cmd('cd %:p:h')

-- load vim-plug
require("plugins._plug")
-- require("plugins.packer")

-- basic settings
require("modules._settings")
require("modules._appearances")

-- plugins config
require("plugins._luatree")
require("plugins._bufferline")
require("plugins._emmet")
require("plugins._indentline")
require("plugins._signify")
require("plugins._telescope")
require("plugins._completion")
require("plugins._formatter")
-- require("plugins._treesitter")
-- require("plugins.compe")
-- require("plugins._coc")

-- lua plugins
require"colorizer".setup{}

-- load modules
require("modules._mappings")
require("modules._statusline")
-- require("modules._theme")
-- require("modules.blur")

-- lsp stuff
require("modules.lsp")

vim.cmd("au TextYankPost * silent! lua vim.highlight.on_yank{ timeout = 250 }")

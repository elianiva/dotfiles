-- change cwd to current directory
vim.cmd('cd %:p:h')

-- load vim-plug
require("plugins._plug")

-- basic settings
require("modules._settings")
require("modules._others")
require("modules._eunoia")
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
-- require("plugins._coc")

-- lua plugins
require"colorizer".setup{}

-- load modules
require("modules._mappings")
require("modules._statusline")
-- require("modules.blur")

-- lsp stuff
require("modules.lsp")

-- change cwd to current directory
vim.cmd('cd %:p:h')

-- load plugin manager first
-- require("plugins._plug")
require("plugins._packer")

-- basic settings
require("modules._settings")
require("modules._others")
require("modules._appearances")
require("modules._util")

-- my colourscheme, not using it, idk why it feels claustrophobic to me
-- when I use it for too long.
-- local eunoia = require("modules._eunoia")
-- eunoia.setup{}
-- ColorUtil.override_eunoia()

-- plugins config
require("plugins._luatree")
require("plugins._bufferline")
require("plugins._emmet")
require("plugins._indentline")
-- require("plugins._signify")
require("plugins._gitsigns")
require("plugins._telescope")
require("plugins._completion")
require("plugins._formatter")
require("plugins._treesitter")
-- require("plugins._coc")

-- highlight bg according to hex/rgb/rgba text
require"colorizer".setup{}

-- load modules
require("modules._mappings")
require("modules._statusline")
-- require("modules.blur")

-- lsp stuff
require("modules.lsp")

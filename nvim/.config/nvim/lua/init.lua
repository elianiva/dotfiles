-- change cwd to current directory
vim.cmd('cd %:p:h')

-- load vim-plug
require("plugins.plug")
-- require("plugins.packer")

-- basic settings
require("modules.settings")
require("modules.appearances")

-- plugins config
require("plugins.luatree")
require("plugins.bufferline")
require("plugins.emmet")
require("plugins.indentline")
require("plugins.signify")
require("plugins.telescope")
require("plugins.completion")
-- require("plugins.compe")
-- require("plugins.coc")

-- lua plugins
require"colorizer".setup{}
require"nvim-web-devicons".setup()

-- load modules
require("modules.mappings")
require("modules.statusline")
-- require("modules.blur")

-- lsp stuff
require("modules.lsp")

vim.cmd("au TextYankPost * silent! lua vim.highlight.on_yank{ timeout = 250 }")

-- basic settings
require("modules.settings")
core_options()

-- lua plugins
require("colorizer").setup{}
require("nvim-web-devicons").setup{}

-- load modules
require("modules.mappings")
require("modules.emmet")
require("modules.bufferline")
require("modules.indentline")
require("modules.luatree")
require("modules.gitgutter")
require("modules.coc")
-- require("modules.lsp")
-- require("modules.statusline")

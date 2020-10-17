-- load vim-plug
require("plugins.plug")

-- basic settings
require("modules.settings")
require("modules.appearances")

-- plugins config
require("plugins.luatree")
require("plugins.bufferline")
require("plugins.emmet")
require("plugins.indentline")
require("plugins.gitgutter")
require("plugins.coc")
require("plugins.fzf")

-- lua plugins
require("colorizer").setup{}
require("nvim-web-devicons").setup{}

-- load modules
require("modules.mappings")
require("modules.statusline")
require("modules.blur")

-- require'telescope'.setup{
--     defaults = {
--         winblend = 0,
--         prompt_position = "top",
--         sorting_strategy = "ascending"
--     }
-- }

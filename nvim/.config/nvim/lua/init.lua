-- basic settings
require("modules.settings")
require("modules.appearances")

-- plugins
-- require("plugins.plug")
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

-- require'telescope'.setup{
--     defaults = {
--         winblend = 0,
--         prompt_position = "top",
--         sorting_strategy = "ascending"
--     }
-- }

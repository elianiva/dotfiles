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
require("modules.fzf")
require("modules.statusline")
-- require("modules.treesitter")
-- require("modules.theme")
-- require("modules.lsp")
-- require("modules.statusline")

-- require'telescope'.setup{
--     defaults = {
--         winblend = 0,
--         prompt_position = "top",
--         sorting_strategy = "ascending"
--     }
-- }

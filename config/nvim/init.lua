-- disable filetype.vim
vim.g.did_load_filetypes = 1

-- enable filetype.lua
vim.g.do_filetype_lua = 1

require("bootstrap")

require("impatient").enable_profile()

-- map leader key to space
vim.g.mapleader = " "
vim.g.maplocalleader = " "

-- prevent typo when pressing `wq` or `q`
vim.cmd [[
cnoreabbrev <expr> W ((getcmdtype() is# ':' && getcmdline() is# 'W')?('w'):('W'))
cnoreabbrev <expr> Q ((getcmdtype() is# ':' && getcmdline() is# 'Q')?('q'):('Q'))
cnoreabbrev <expr> WQ ((getcmdtype() is# ':' && getcmdline() is# 'WQ')?('wq'):('WQ'))
cnoreabbrev <expr> Wq ((getcmdtype() is# ':' && getcmdline() is# 'Wq')?('wq'):('Wq'))
]]

-- order matters
vim.cmd [[
runtime! lua/deps.lua
runtime! lua/modules/options.lua
runtime! lua/modules/util.lua
runtime! lua/modules/mappings.lua
runtime! lua/modules/statusline.lua
]]

vim.cmd [[ colorscheme gitgud_dark ]]

vim.g.mapleader = " "
vim.g.maplocalleader = " "

-- prevent typo when pressing `wq` or `q`
vim.cmd [[
  cnoreabbrev <expr> W ((getcmdtype() is# ':' && getcmdline() is# 'W')?('w'):('W'))
  cnoreabbrev <expr> Q ((getcmdtype() is# ':' && getcmdline() is# 'Q')?('q'):('Q'))
  cnoreabbrev <expr> WQ ((getcmdtype() is# ':' && getcmdline() is# 'WQ')?('wq'):('WQ'))
  cnoreabbrev <expr> Wq ((getcmdtype() is# ':' && getcmdline() is# 'Wq')?('wq'):('Wq'))
]]

-- change cwd to current directory
vim.cmd [[cd %:p:h]]
pcall(require, "plugins._packer")

pcall(require, "modules._settings") -- `set` stuff
pcall(require, "modules._appearances") -- colourscheme shenanigans
pcall(require, "modules._util") -- some useful utils
pcall(require, "modules._mappings") -- general mappings
pcall(require, "modules._statusline") -- my custom statusline

pcall(require, "plugins._bufferline") -- nvim-bufferline + extra stuff
pcall(require, "plugins._compe") -- completion config
-- pcall(require, "plugins._emmet") -- not using this anymore
pcall(require, "plugins._firenvim") -- firenvim stuff
pcall(require, "plugins._formatter") -- formatter configuration
pcall(require, "plugins._gitsigns") -- gitsings config
pcall(require, "plugins._nvimtree") -- nvimtree config
-- pcall(require, "plugins._snippets") -- snippets config
require("plugins._snippets")
pcall(require, "plugins._telescope") -- to see planets and stars
pcall(require, "plugins._treesitter") -- something awesome

pcall(require, "modules._others") -- other stuff

pcall(require, "modules.lsp") -- lsp related stuff

vim.g.mapleader = "\\"
vim.g.maplocalleader = "\\"

-- prevent typo when pressing `wq` or `q`
vim.cmd[[
  cnoreabbrev <expr> W ((getcmdtype() is# ':' && getcmdline() is# 'W')?('w'):('W'))
  cnoreabbrev <expr> Q ((getcmdtype() is# ':' && getcmdline() is# 'Q')?('q'):('Q'))
  cnoreabbrev <expr> WQ ((getcmdtype() is# ':' && getcmdline() is# 'WQ')?('wq'):('WQ'))
  cnoreabbrev <expr> Wq ((getcmdtype() is# ':' && getcmdline() is# 'Wq')?('wq'):('Wq'))
]]

-- change cwd to current directory
vim.cmd("cd %:p:h")
require("plugins._packer")

-- load modules
require("modules._settings")
require("modules._appearances")
require("modules._util")
require("modules._others")
require("modules._mappings")
require("modules._statusline")

require("plugins._autopairs")
require("plugins._bufferline")
require("plugins._compe")
require("plugins._emmet")
require("plugins._firenvim")
require("plugins._formatter")
require("plugins._gitsigns")
require("plugins._nvimtree")
require("plugins._snippets")
require("plugins._telescope")
require("plugins._treesitter")

-- lsp stuff
require("modules.lsp")

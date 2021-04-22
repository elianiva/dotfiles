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

-- order matters
local modules = {
  "plugins._packer",

  -- plugin unrelated(-ish) stuff
  "modules._settings",    -- `set` stuff
  "modules._appearances", -- colourscheme shenanigans
  "modules._util",        -- some useful utils
  "modules._mappings",    -- general mappings
  "modules._statusline",  -- my custom statusline

  -- plugin related stuff
  "plugins._bufferline",  -- nvim-bufferline + extra stuff
  "plugins._compe",       -- completion config
  "plugins._firenvim",    -- firenvim stuff
  "plugins._formatter",   -- formatter configuration
  "plugins._gitsigns",    -- gitsings config
  "plugins._nvimtree",    -- nvimtree config
  "plugins._snippets",    -- snippets config
  "plugins._telescope",   -- to see planets and stars
  "plugins._treesitter",  -- something awesome

  -- some stuff
  "modules._others",

  -- lsp stuff
  "modules.lsp",
}

local errors = {}
for _, v in pairs(modules) do
  local ok, err = pcall(require, v)
  if not ok then
    table.insert(errors, err)
  end
end

if not vim.tbl_isempty(errors) then
  for _, v in pairs(errors) do
    print(v)
  end
end

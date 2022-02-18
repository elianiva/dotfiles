local repos = {
  lewis6991 = { "impatient.nvim", "impatient" },
  tani = { "vim-jetpack", "jetpack" },
}

for user, repo in pairs(repos) do
  local install_path = vim.fn.stdpath "data"
    .. "/site/pack/"
    .. repo[2]
    .. "/start/"
    .. repo[1]

  if vim.fn.empty(vim.fn.glob(install_path)) == 1 then
    vim.cmd(
      string.format(
        [[execute "!git clone --depth=1 https://github.com/%s/%s %s"]],
        user,
        repo[1],
        install_path
      )
    )
    vim.cmd("packadd " .. repo[1])
  end
end

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

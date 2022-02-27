local jetpack_path = vim.fn.stdpath("data") .. "/site/pack/jetpack"
if vim.fn.empty(vim.fn.glob(jetpack_path)) == 1 then
  vim.cmd(string.format([[
    execute "!git clone --depth 1 https://github.com/tani/vim-jetpack %s/src/vim-jetpack"
    execute "!mkdir %s/opt/"
    execute "!ln -s %s"
  ]], jetpack_path, jetpack_path, jetpack_path .. "/{src,opt}/vim-jetpack"))
end

local impatient_path = vim.fn.stdpath("data") .. "/site/pack/impatient.nvim/start/impatient.nvim"
if vim.fn.empty(vim.fn.glob(impatient_path)) == 1 then
  vim.cmd(string.format([[
    execute "!git clone --depth 1 https://github.com/lewis6991/impatient.nvim %s"
  ]], impatient_path))
end

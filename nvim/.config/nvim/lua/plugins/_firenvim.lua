if vim.fn.exists("g:started_by_firenvim") == 1 then
  vim.cmd [[set laststatus=0]]
  vim.cmd [[set showtabline=0]]
  vim.cmd [[set guifont=JetBrainsMono:h11]]
end

vim.g.firenvim_config = {
  localSettings = {
    [".*"] = {
      takeover = "never",
      priority = 1,
    },
  },
}

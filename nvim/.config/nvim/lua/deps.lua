vim.g.mapleader = " "

require("lazy").setup("plugins", {
  performance = {
    rtp = {
      disabled_plugins = { "tohtml", "gzip", "matchit", "zipPlugin", "netrwPlugin", "tarPlugin" },
    },
  },
})

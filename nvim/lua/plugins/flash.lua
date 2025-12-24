return {
  "folke/flash.nvim",
  event = "VeryLazy",
  ---@type Flash.Config
  opts = {},
  keys = {
    { "gw", mode = { "n", "x", "o" }, function() require("flash").jump() end, desc = "Flash" },
  },
}

return {
  "folke/which-key.nvim",
  lazy = false,
  keys = {
    {
      "<leader>?",
      function() require("which-key").show({ global = false }) end,
      desc = "Buffer Local Keymaps (which-key)",
    },
    {
      "<leader>gs",
      function() require("which-key").show({ group = "gs" }) end,
      desc = "Gitsigns",
    }
  }
}

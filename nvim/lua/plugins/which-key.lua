return {
  "folke/which-key.nvim",
  event = "VeryLazy",
  keys = {
    {
      "<leader>?",
      function() require("which-key").show({ global = false }) end,
      desc = "Buffer Local Keymaps (which-key)",
    },
    {
      "<leader>f",
      function() require("which-key").show({ group = "f" }) end,
      desc = "Picker",
    },
    {
      "<leader>fl",
      function() require("which-key").show({ group = "fl" }) end,
      desc = "Picker (LSP)",
    },
    {
      "<leader>d",
      function() require("which-key").show({ group = "d" }) end,
      desc = "Dadbod",
    },
    {
      "<leader>gs",
      function() require("which-key").show({ group = "gs" }) end,
      desc = "Gitsigns",
    }
  }
}

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
      desc = "Telescope",
    },
    {
      "<leader>fl",
      function() require("which-key").show({ group = "fl" }) end,
      desc = "Telescope LSP Actions",
    },
    {
      "<leader>j",
      function() require("which-key").show({ group = "j" }) end,
      desc = "Flash.nvim",
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

return {
  {
    "windwp/nvim-ts-autotag",
  },
  {
    "windwp/nvim-autopairs",
    event = "VeryLazy",
    config = function(_, opts)
      require("nvim-autopairs").setup(opts)
    end
  }
}

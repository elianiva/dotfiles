return {
  {
    "ruifm/gitlinker.nvim",
    dependencies = {
      "nvim-lua/plenary.nvim"
    },
    config = function(_, opts)
      require("gitlinker").setup(opts)
    end
  }
}

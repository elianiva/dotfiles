return {
  {
    "phaazon/hop.nvim",
    config = function(_, opts)
      require("hop").setup()
    end,
    keys = {
      {
        "<leader>w",
        "<CMD>HopWord<CR>",
        noremap = true,
        silent = true
      }
    }
  }
}

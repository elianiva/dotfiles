return {
  {
    "NvChad/nvim-colorizer.lua",
    opts = {
      ["*"] = {
        css = true,
        css_fn = true,
        mode = "background",
      },
    },
    keys = {
      {
        "<leader>c",
        function()
          vim.cmd [[ColorizerToggle]]
        end,
        silent = true,
        mode = "n"
      }
    },
    config = function(_, opts)
      require("colorizer").setup(opts)
    end
  }
}

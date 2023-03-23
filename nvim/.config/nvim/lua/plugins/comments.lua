return {
  {
    "numToStr/Comment.nvim",
    dependencies = {
      "JoosepAlviste/nvim-ts-context-commentstring",
    },
    event = "VeryLazy",
    opts = {
      ignore = "^$",
      -- pre_hook = require('ts_context_commentstring.integrations.comment_nvim').create_pre_hook(),
    },
    config = function(_, opts)
      require("Comment").setup(opts)
    end
  }
}

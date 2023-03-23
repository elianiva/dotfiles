return {
  {
    "lewis6991/gitsigns.nvim",
    event = { "BufReadPre", "BufNewFile" },
    dependencies = {
      "nvim-lua/plenary.nvim",
    },
    opts = {
      signs = {
        add          = { hl = "SignAdd",    text = "▎" },
        change       = { hl = "SignChange", text = "▎" },
        delete       = { hl = "SignDelete", text = "" },
        topdelete    = { hl = "SignDelete", text = "" },
        changedelete = { hl = "SignChange", text = "▎" },
      },
      on_attach = function(bufnr)
        local gs = package.loaded.gitsigns

        local function map(mode, l, r, opts)
          vim.keymap.set(mode, l, r, opts)
        end

        map("n", "<leader>hn", "&diff ? ']c' : '<cmd>Gitsigns next_hunk<CR>'", { expr = true, desc = "Next git hunk" })
        map("n", "<leader>hp", "&diff ? '[c' : '<cmd>Gitsigns prev_hunk<CR>'", { expr = true, desc = "Previous git hunk" })
        map("n", "<leader>hs", gs.stage_hunk, { desc = "Stage Hunk" })
        map("n", "<leader>hu", gs.undo_stage_hunk, { desc = "Undo staging hunk" })
        map({ "n", "v" }, "<leader>hr", "<CMD>Gitsigns reset_hunk<CR>", { desc = "Reset hunk" })
        map("n", "<leader>hb", gs.blame_line, { desc = "Blame line" })
        map("n", "<leader>hR", gs.reset_buffer, { desc = "Reset buffer" })
        map("n", "<leader>hP", gs.preview_hunk, { desc = "Preview hunk" })
      end,
      current_line_blame = false,
      sign_priority = 5,
      update_debounce = 500,
      status_formatter = nil, -- Use default
      diff_opts = {
        internal = true,
      },
    },
    config = function(_, opts)
      require("gitsigns").setup(opts)
    end
  }
}

return {
  "lewis6991/gitsigns.nvim",
  cond = function()
    -- only load on git repo
    local git_path = vim.uv.cwd() .. "/.git"
    local ok, err = vim.uv.fs_stat(git_path)

    if not ok then
      local gitignore_path = vim.uv.cwd() .. "/.gitignore"
      ok, err = vim.uv.fs_stat(gitignore_path)
    end

    return ok and err == nil
  end,
  keys = {
    { "<leader>gsl", "<cmd>Gitsigns blame_line<cr>", desc = "Blame Line" },
    { "<leader>gsb", "<cmd>Gitsigns blame<cr>", desc = "Blame Buffer" },
    { "<leader>gsd", "<cmd>Gitsigns diffthis<cr>", desc = "Diff This" },
    { "<leader>gss", "<cmd>Gitsigns stage_hunk<cr>", desc = "Stage Hunk" },
    { "<leader>gsp", "<cmd>Gitsigns preview_hunk<cr>", desc = "Preview Hunk" },
    { "<leader>gsr", "<cmd>Gitsigns reset_hunk<cr>", desc = "Reset Hunk" },
    { "<leader>gsR", "<cmd>Gitsigns reset_buffer<cr>", desc = "Reset Buffer" },
    { "<leader>gsh", "<cmd>Gitsigns reset_hunk<cr>", desc = "Reset Hunk" },
    { "<leader>gsH", "<cmd>Gitsigns reset_buffer<cr>", desc = "Reset Buffer" },
  },
  opts = {
    current_line_blame_formatter = '<author>, <author_time:%R> - <summary>',
    current_line_blame_opts = {
      virt_text = true,
      virt_text_pos = 'eol',
      virt_text_priority = 100
    },
    signs = {
      add = { text = "▎" },
      change = { text = "▎" },
      delete = { text = "" },
      topdelete = { text = "" },
      changedelete = { text = "▎" },
      untracked = { text = "▎" },
    },
    signs_staged = {
      add = { text = "▎" },
      change = { text = "▎" },
      delete = { text = "" },
      topdelete = { text = "" },
      changedelete = { text = "▎" },
    },
    on_attach = function(buffer)
      local gs = package.loaded.gitsigns

      local function map(mode, l, r, desc)
        vim.keymap.set(mode, l, r, { buffer = buffer, desc = desc })
      end

      -- stylua: ignore start
      map("n", "]h", function()
        if vim.wo.diff then
          vim.cmd.normal({ "]c", bang = true })
        else
          gs.nav_hunk("next")
        end
      end, "Next Hunk")
      map("n", "[h", function()
        if vim.wo.diff then
          vim.cmd.normal({ "[c", bang = true })
        else
          gs.nav_hunk("prev")
        end
      end, "Prev Hunk")
      map("n", "]H", function() gs.nav_hunk("last") end, "Last Hunk")
      map("n", "[H", function() gs.nav_hunk("first") end, "First Hunk")
    end,
  },
}

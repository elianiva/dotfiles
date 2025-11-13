return {
  "echasnovski/mini.surround",
  event = "VeryLazy",
  opts = {
    -- Module mappings. Use `''` (empty string) to disable one.
    mappings = {
      add = 'ma', -- Add surrounding in Normal and Visual modes
      delete = 'md', -- Delete surrounding
      find = 'mf', -- Find surrounding (to the right)
      find_left = 'mF', -- Find surrounding (to the left)
      highlight = 'mh', -- Highlight surrounding
      replace = 'mr', -- Replace surrounding
      update_n_lines = 'sn', -- Update `n_lines`

      suffix_last = 'l', -- Suffix to search with "prev" method
      suffix_next = 'n', -- Suffix to search with "next" method
    },
  },
}

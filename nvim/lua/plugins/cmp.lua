return {
  'saghen/blink.cmp',
  lazy = false,    -- lazy loading handled internally
  dependencies = 'rafamadriz/friendly-snippets',
  version = "v0.*", -- last release is too old
  event = "InsertEnter",
  opts = {
    keymap = {
      accept = '<CR>',
      snippet_forward = '<C-j>',
      snippet_backward = '<C-k>',
    },
    windows = {
      autocomplete = {
        border = "single",
      },
      documentation = {
        border = "single"
      },
      signature_help = {
        border = "single"
      }
    },
    highlight = {
      use_nvim_cmp_as_default = true,
    },
    fuzzy = {
      -- frencency tracks the most recently/frequently used items and boosts the score of the item
      use_frecency = true,
      -- proximity bonus boosts the score of items with a value in the buffer
      use_proximity = true,
      max_items = 200,
      -- controls which sorts to use and in which order, these three are currently the only allowed options
      sorts = { 'label', 'kind', 'score' },

      prebuiltBinaries = {
        -- Whether or not to automatically download a prebuilt binary from github. If this is set to `false`
        -- you will need to manually build the fuzzy binary dependencies by running `cargo build --release`
        download = true,
        -- When downloading a prebuilt binary force the downloader to resolve this version. If this is uset
        -- then the downloader will attempt to infer the version from the checked out git tag (if any).
        --
        -- Beware that if the FFI ABI changes while tracking main then this may result in blink breaking.
        forceVersion = nil,
      },
    },
    nerd_font_variant = 'normal',
    accept = { auto_brackets = { enabled = true } },
    trigger = { signature_help = { enabled = false, show_on_insert_on_trigger_character = false } }
  }
}

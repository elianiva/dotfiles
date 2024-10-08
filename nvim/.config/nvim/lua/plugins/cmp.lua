return {
  'saghen/blink.cmp',
  lazy = false, -- lazy loading handled internally
  dependencies = 'rafamadriz/friendly-snippets',
  version = 'v0.*',
  opts = {
    keymap = {
      accept = '<CR>',
      snippet_forward = '<C-j>',
      snippet_backward = '<C-k>',
    },
    windows = {
      autocomplete = {
        border = require('config.utils').borders,
      },
      documentation = {
        border = require('config.utils').borders,
      },
      signature_help = {
        border = require('config.utils').borders,
      }
    },
    highlight = {
      use_nvim_cmp_as_default = true,
    },
    nerd_font_variant = 'normal',
    accept = { auto_brackets = { enabled = true } },
    trigger = { signature_help = { enabled = false, show_on_insert_on_trigger_character = false } }
  }
}

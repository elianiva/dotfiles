return {
  "williamboman/mason.nvim",
  cmd = { "Mason" },
  build = ":MasonUpdate",
  opts_extend = { "ensure_installed" },
  opts = {
    ensure_installed = {
      "html-lsp",
      "css-lsp",
      "basedpyright",
      "ruff",
      "astro-language-server",
      "tailwindcss-language-server",
      "typescript-language-server",
      "yaml-language-server",
      "lua-language-server",
      "json-lsp",
      "tinymist"
    }
  },
}

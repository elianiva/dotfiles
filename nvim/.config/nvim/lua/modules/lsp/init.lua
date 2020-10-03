local nvim_lsp = require("nvim_lsp")

require("modules.lsp.svelte")

nvim_lsp.tsserver.setup{
    filetypes = { "javascript", "typescript", "typescriptreact" }
}

nvim_lsp.html.setup{}
nvim_lsp.cssls.setup{}
nvim_lsp.svelte.setup{}

require("modules.lsp.settings")
require("modules.lsp.mappings")

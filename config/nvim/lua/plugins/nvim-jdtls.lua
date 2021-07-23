local M = {}

M.plugin = {
  "mfussenegger/nvim-jdtls",
  wants = "telescope.nvim",
  setup = function()
    vim.cmd [[
      augroup jdtls
      au!
      au FileType java lua require("plugins.nvim-jdtls").setup()
      augroup END
    ]]
  end,
}

M.setup = function()
  require("jdtls").start_or_attach {
    cmd = { vim.env.HOME .. "/.scripts/run_jdtls" },
    on_attach = function(client)
      if client.resolved_capabilities.code_lens then
        vim.cmd [[
          augroup CodeLens
            au!
            au CursorHold,CursorHoldI * lua vim.lsp.codelens.refresh()
          augroup END
        ]]
      end

      require("modules.lsp.mappings").lsp_mappings()
    end,
  }
end

return M

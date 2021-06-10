local M = {}

M.config = function()
  vim.cmd [[
    augroup jdtls
    au!
    au FileType java lua require"modules.lsp._jdtls".setup()
    augroup END
  ]]
end

M.setup = function()
  require("jdtls").start_or_attach({
    cmd = { vim.env.HOME .. "/.scripts/run_jdtls" },
    on_attach = function()
      require("modules.lsp._mappings").lsp_mappings("jdtls")
      require("lsp_signature").on_attach {
        bind = true,
        doc_lines = 2,
        hint_enable = false,
        handler_opts = {
          border = Util.borders
        }
      }
    end,
  })
end

return M

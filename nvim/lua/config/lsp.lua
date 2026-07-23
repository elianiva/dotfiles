local util = require("lspconfig.util")
local capabilities = vim.lsp.protocol.make_client_capabilities()
capabilities.textDocument.foldingRange = {
  dynamicRegistration = false,
  lineFoldingOnly = true,
}
capabilities.textDocument.semanticTokens.multilineTokenSupport = true

local ok, blink = pcall(require, "blink.cmp")
if ok then
  capabilities = vim.tbl_deep_extend("force", capabilities, blink.get_lsp_capabilities(capabilities))
end

-- global lsp settings
vim.lsp.config("*", {
  capabilities = capabilities,
})

-- intelephense specific settings
local intelephense_capabilities = vim.lsp.protocol.make_client_capabilities()
intelephense_capabilities.textDocument.completion.dynamicRegistration = true
vim.lsp.config("intelephense", {
  capabilities = intelephense_capabilities
})

-- basedpyright specific settings
vim.lsp.config("basedpyright", {
  settings = {
    basedpyright = {
      analysis = {
        autoSearchPaths = true,
        diagnosticMode = "workspace",
        useLibraryCodeForTypes = true,
        diagnosticSeverityOverrides = {
          reportUnknownVariableType = false,
        },
      },
    },
  }
})

-- use harper for markdown and typst
vim.lsp.config("harper_ls", {
  filetypes = { "markdown", "typst" }
})

local function project_bin(name)
  local cwd = vim.fn.getcwd()
  local bin = vim.fn.findfile("node_modules/.bin/" .. name, cwd .. ";")
  if bin ~= "" then
    return vim.fn.fnamemodify(bin, ":p")
  end
  return name
end

vim.lsp.config("oxfmt", {
  cmd = { project_bin("oxfmt"), "--lsp" },
  filetypes = {
    "javascript",
    "javascriptreact",
    "typescript",
    "typescriptreact",
    "toml",
    "json",
    "jsonc",
    "json5",
    "yaml",
    "html",
    "vue",
    "handlebars",
    "css",
    "scss",
    "less",
    "graphql",
    "markdown",
  },
  root_markers = { ".oxfmtrc.json", ".oxfmtrc.jsonc", "oxfmt.config.ts", "vite.config.ts", "vite.config.js" },
  autostart = true,
})

vim.lsp.config("oxlint", {
  cmd = { project_bin("oxlint"), "--lsp" },
  root_markers = { ".git", ".oxlintrc.json", ".oxlintrc.jsonc", "vite.config.ts" },
  settings = {
    typeAware = true,
    configPath = "./vite.config.ts"
  }
})

vim.api.nvim_create_autocmd("LspAttach", {
  callback = function(args)
    local utils = require("config.utils")
    local client = vim.lsp.get_client_by_id(args.data.client_id)

    if client == nil then
      return
    end

    -- trigger additional capabilities
    utils.lsp.additional_capabilities(client)

    -- Setup buffer-specific mappings
    utils.lsp.additional_mappings(args.buf)

    -- Setup buffer-specific autocmds for this LSP client
    -- if client:supports_method("textDocument/codeLens", args.buf) then
    --   local group = vim.api.nvim_create_augroup("lsp_codelens_" .. args.buf, { clear = true })
    --   vim.api.nvim_create_autocmd({ "InsertEnter", "InsertLeave" }, {
    --     group = group,
    --     buffer = args.buf,
    --     callback = function()
    --       vim.lsp.codelens.refresh()
    --     end,
    --   })
    -- end

    if client:supports_method("textDocument/documentHighlight", args.buf) then
      local group = vim.api.nvim_create_augroup("lsp_document_highlight_" .. args.buf, { clear = true })
      vim.api.nvim_create_autocmd("CursorHold", {
        group = group,
        buffer = args.buf,
        callback = function()
          vim.lsp.buf.document_highlight()
        end,
      })
      vim.api.nvim_create_autocmd("CursorHoldI", {
        group = group,
        buffer = args.buf,
        callback = function()
          vim.lsp.buf.document_highlight()
        end,
      })
      vim.api.nvim_create_autocmd("CursorMoved", {
        group = group,
        buffer = args.buf,
        callback = function()
          vim.lsp.buf.clear_references()
        end,
      })
    end
  end
})

vim.api.nvim_create_autocmd('LspProgress', {
  callback = function(ev)
    local value = ev.data.params.value
    vim.api.nvim_echo({ { value.message or 'done' } }, false, {
      id = 'lsp.' .. ev.data.client_id,
      kind = 'progress',
      source = 'vim.lsp',
      title = value.title,
      status = value.kind ~= 'end' and 'running' or 'success',
      percent = value.percentage,
    })
  end,
})

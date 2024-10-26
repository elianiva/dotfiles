local M = {}
M.lsp = {}

M.CREATE_UNDO = vim.api.nvim_replace_termcodes("<c-G>u", true, true, true)
function M.create_undo()
  if vim.api.nvim_get_mode().mode == "i" then
    vim.api.nvim_feedkeys(M.CREATE_UNDO, "n", false)
  end
end

M.borders = {
  -- fancy border
  { "🭽", "FloatBorder" },
  { "▔", "FloatBorder" },
  { "🭾", "FloatBorder" },
  { "▕", "FloatBorder" },
  { "🭿", "FloatBorder" },
  { "▁", "FloatBorder" },
  { "🭼", "FloatBorder" },
  { "▏", "FloatBorder" },

  -- padding border
  -- {"▄", "PaddingBorder"},
  -- {"▄", "PaddingBorder"},
  -- {"▄", "PaddingBorder"},
  -- {"█", "PaddingBorder"},
  -- {"▀", "PaddingBorder"},
  -- {"▀", "PaddingBorder"},
  -- {"▀", "PaddingBorder"},
  -- {"█", "PaddingBorder"}
}

M.nui_borders = vim.tbl_map(function(x) return x[1] end, M.borders)

M.completion_icons = {
  Array         = " ",
  Boolean       = "󰨙 ",
  Class         = " ",
  Codeium       = "󰘦 ",
  Color         = " ",
  Control       = " ",
  Collapsed     = " ",
  Constant      = "󰏿 ",
  Constructor   = " ",
  Copilot       = " ",
  Enum          = " ",
  EnumMember    = " ",
  Event         = " ",
  Field         = " ",
  File          = " ",
  Folder        = " ",
  Function      = "󰊕 ",
  Interface     = " ",
  Key           = " ",
  Keyword       = " ",
  Method        = "󰊕 ",
  Module        = " ",
  Namespace     = "󰦮 ",
  Null          = " ",
  Number        = "󰎠 ",
  Object        = " ",
  Operator      = " ",
  Package       = " ",
  Property      = " ",
  Reference     = " ",
  Snippet       = " ",
  String        = " ",
  Struct        = "󰆼 ",
  TabNine       = "󰏚 ",
  Text          = " ",
  TypeParameter = " ",
  Unit          = " ",
  Value         = " ",
  Variable      = "󰀫 ",
}

-- integrate rename with lsp
function M.lsp.on_rename(from, to, rename)
  local changes = {
    files = { {
      oldUri = vim.uri_from_fname(from),
      newUri = vim.uri_from_fname(to),
    } }
  }

  local clients = M.get_clients()
  for _, client in ipairs(clients) do
    if client.supports_method("workspace/willRenameFiles") then
      local resp = client.request_sync("workspace/willRenameFiles", changes, 1000, 0)
      if resp and resp.result ~= nil then
        vim.lsp.util.apply_workspace_edit(resp.result, client.offset_encoding)
      end
    end
  end

  if rename then
    rename()
  end

  for _, client in ipairs(clients) do
    if client.supports_method("workspace/didRenameFiles") then
      client.notify("workspace/didRenameFiles", changes)
    end
  end
end

function M.lsp.additional_capabilities(client)
  if client.supports_method("textDocument/codeLens") then
    vim.cmd [[
    augroup CodeLens
      au!
      au InsertEnter,InsertLeave * lua vim.lsp.codelens.refresh()
    augroup END
    ]]
  end

  if client.supports_method("textDocument/documentHighlight") then
    vim.cmd [[
    augroup DocumentHighlight
      au!
      autocmd CursorHold  <buffer> lua vim.lsp.buf.document_highlight()
      autocmd CursorHoldI <buffer> lua vim.lsp.buf.document_highlight()
      autocmd CursorMoved <buffer> lua vim.lsp.buf.clear_references()
    augroup END
    ]]
  end

  if client.supports_method("textDocument/inlayHint") then
    vim.lsp.inlay_hint.enable(true)
  end
end

function M.lsp.additional_mappings(bufnr)
  vim.keymap.set("i", "<C-s>", vim.lsp.handlers.signature_help, {
    desc = "Trigger signature help from the language server",
    noremap = true,
    silent = true,
    buffer = bufnr,
  })

  vim.keymap.set("n", "K", vim.lsp.buf.hover, {
    desc = "Trigger hover window from the language server",
    noremap = true,
    silent = true,
    buffer = bufnr,
  })

  vim.keymap.set("n", "<Leader>ga", vim.lsp.buf.code_action, {
    desc = "Pick code actions from the language server",
    noremap = true,
    silent = true,
    buffer = bufnr,
  })

  vim.keymap.set("n", "<Leader>gd", vim.lsp.buf.definition, {
    desc = "Go to symbol definition",
    noremap = true,
    silent = true,
    buffer = bufnr,
  })

  vim.keymap.set("n", "<Leader>gl", vim.lsp.codelens.run, {
    desc = "Run codelens from the language server",
    noremap = true,
    silent = true,
    buffer = bufnr,
  })

  vim.keymap.set("n", "<Leader>gD", function()
    vim.diagnostic.open_float({
      bufnr = bufnr,
      severity_sort = true,
      header = "",
      scope = "line",
      border = "solid"
    })
  end, {
    desc = "See diagnostics in floating window",
    noremap = true,
    silent = true,
    buffer = bufnr,
  })

  vim.keymap.set("n", "<Leader>gr", vim.lsp.buf.references, {
    desc = "Show references",
    noremap = true,
    silent = true,
    buffer = bufnr,
  })

  vim.keymap.set("n", "<Leader>gR", vim.lsp.buf.rename, {
    desc = "Rename current symbol",
    noremap = true,
    silent = true,
    buffer = bufnr,
  })

  vim.keymap.set("n", "]d", function()
    vim.diagnostic.goto_next {
      float = { show_header = false, border = "solid" },
    }
  end, {
    desc = "Go to next diagnostic",
    noremap = true,
    silent = true,
    buffer = bufnr,
  })

  vim.keymap.set("n", "[d", function()
    vim.diagnostic.goto_prev {
      float = { show_header = false, border = "solid" },
    }
  end, {
    desc = "Go to previous diagnostic",
    noremap = true,
    silent = true,
    buffer = bufnr,
  })
end

return M

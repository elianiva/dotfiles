local M = {}
M.lsp = {}

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

function M.lsp.additional_capabilities(client)
	if client.supports_method("textDocument/codeLens") then
		vim.lsp.codelens.refresh()
	end

	if client.supports_method("textDocument/inlayHint") then
		vim.lsp.inlay_hint.enable(true)
	end
end

function M.lsp.additional_mappings(bufnr)
	vim.keymap.set("i", "<C-s>", vim.lsp.buf.signature_help, {
		desc = "Trigger signature help from the language server",
		noremap = true,
		silent = true,
		buffer = bufnr,
	})

	vim.keymap.set("n", "<Leader>k", vim.lsp.buf.hover, {
		desc = "Trigger hover window from the language server",
		noremap = true,
		silent = true,
		buffer = bufnr,
	})

	vim.keymap.set("n", "<Leader>a", vim.lsp.buf.code_action, {
		desc = "Pick code actions from the language server",
		noremap = true,
		silent = true,
		buffer = bufnr,
	})

	vim.keymap.set("n", "gd", vim.lsp.buf.definition, {
		desc = "Go to symbol definition",
		noremap = true,
		silent = true,
		buffer = bufnr,
	})

	vim.keymap.set("n", "<Leader>l", vim.lsp.codelens.run, {
		desc = "Run codelens from the language server",
		noremap = true,
		silent = true,
		buffer = bufnr,
	})

	vim.keymap.set("n", "<Leader>d", function()
		vim.diagnostic.open_float({
			bufnr = bufnr,
			header = "",
			scope = "line",
		})
	end, {
		desc = "See line diagnostics in floating window",
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

	vim.keymap.set("n", "<Leader>r", vim.lsp.buf.rename, {
		desc = "Rename current symbol",
		noremap = true,
		silent = true,
		buffer = bufnr,
	})

	vim.keymap.set("n", "]d", function()
		vim.diagnostic.jump({
      count = 1,
			float = { show_header = false },
		})
	end, {
		desc = "Go to next diagnostic",
		noremap = true,
		silent = true,
		buffer = bufnr,
	})

	vim.keymap.set("n", "[d", function()
		vim.diagnostic.jump({
      count = -1,
			float = { show_header = false },
		})
	end, {
		desc = "Go to previous diagnostic",
		noremap = true,
		silent = true,
		buffer = bufnr,
	})
end

return M

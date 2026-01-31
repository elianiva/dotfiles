return {
	"kevinhwang91/nvim-ufo",
	dependencies = {
		"kevinhwang91/promise-async",
	},
	event = { "BufRead", "BufNewFile" },
	keys = {
    -- stylua: ignore start
    { "zm", function() require("ufo").closeAllFolds() end, desc = "󱃄 Close All Folds" },
    { "zr", function()
      require("ufo").openFoldsExceptKinds { "comment", "imports" }
      vim.opt.scrolloff = vim.g.baseScrolloff -- fix scrolloff setting sometimes being off
    end, desc = "󱃄 Open All Regular Folds" },
    { "zR", function() require("ufo").openFoldsExceptKinds {} end, desc = "󱃄 Open All Folds" },
    { "z1", function() require("ufo").closeFoldsWith(1) end, desc = "󱃄 Close L1 Folds" },
    { "z2", function() require("ufo").closeFoldsWith(2) end, desc = "󱃄 Close L2 Folds" },
    { "z3", function() require("ufo").closeFoldsWith(3) end, desc = "󱃄 Close L3 Folds" },
    { "z4", function() require("ufo").closeFoldsWith(4) end, desc = "󱃄 Close L4 Folds" },
		-- stylua: ignore end
	},
	opts = {
		provider_selector = function(_, ft, _)
			-- INFO some filetypes only allow indent, some only LSP, some only
			-- treesitter. However, ufo only accepts two kinds as priority,
			-- therefore making this function necessary :/
			local lspWithOutFolding = { "markdown", "zsh", "css", "html", "python", "json" }
			if vim.tbl_contains(lspWithOutFolding, ft) then
				return { "treesitter", "indent" }
			end
			return { "lsp", "indent" }
		end,
		fold_virt_text_handler = function(virtText, lnum, endLnum, width, truncate)
			local hlgroup = "NonText"
			local newVirtText = {}
			local suffix = "   " .. tostring(endLnum - lnum)
			local sufWidth = vim.fn.strdisplaywidth(suffix)
			local targetWidth = width - sufWidth
			local curWidth = 0
			for _, chunk in ipairs(virtText) do
				local chunkText = chunk[1]
				local chunkWidth = vim.fn.strdisplaywidth(chunkText)
				if targetWidth > curWidth + chunkWidth then
					table.insert(newVirtText, chunk)
				else
					chunkText = truncate(chunkText, targetWidth - curWidth)
					local hlGroup = chunk[2]
					table.insert(newVirtText, { chunkText, hlGroup })
					chunkWidth = vim.fn.strdisplaywidth(chunkText)
					if curWidth + chunkWidth < targetWidth then
						suffix = suffix .. (" "):rep(targetWidth - curWidth - chunkWidth)
					end
					break
				end
				curWidth = curWidth + chunkWidth
			end
			table.insert(newVirtText, { suffix, hlgroup })
			return newVirtText
		end,
	},
	init = function()
		vim.o.foldcolumn = "1" -- '0' is not bad
		vim.o.foldlevel = 99 -- Using ufo provider need a large value, feel free to decrease the value
		vim.o.foldlevelstart = 99
		vim.o.foldenable = true
	end,
}

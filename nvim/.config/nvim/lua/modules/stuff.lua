local lsp = vim.lsp
local api = vim.api

local all_diag = lsp.diagnostic.get_all()

vim.cmd [[ 10new ]]
vim.cmd [[ hi StuffWarning gui=bold guifg=#d79921 ]]

local result_bufnr = api.nvim_get_current_buf()
local ns = api.nvim_create_namespace("stuff")

api.nvim_buf_set_keymap(result_bufnr, "n", "<C-c>", "<CMD>bd!<CR>", { silent = true })
api.nvim_buf_set_keymap(result_bufnr, "n", "q", "<CMD>bd!<CR>", { silent = true })

local i = 0
for bufnr, diag in pairs(all_diag) do
  if #diag ~= 0 then
    local filename = vim.fn.fnamemodify(api.nvim_buf_get_name(bufnr), ":t")
    local icon, hl_group = require("nvim-web-devicons").get_icon(filename, vim.fn.fnamemodify(filename, ":e"), { default = true })
    P(i)
    api.nvim_buf_set_lines(0, i, -1, false, {icon.."  "..filename})
    api.nvim_buf_add_highlight(result_bufnr, ns, hl_group, i, 0, 3)
    -- api.nvim_buf_add_highlight(result_bufnr, ns, "StuffFilename", i, 3, -1)

    for k, v in ipairs(diag) do
      i = i + k + 1
      api.nvim_buf_set_lines(0, i, -1, false, {
        string.format("    [%s] %s", v.code, v.message)
      })
      api.nvim_buf_add_highlight(
        result_bufnr, ns, "StuffWarning", k + i - 2, 5, #v.code + 9
      )
    end
  end
end

api.nvim_buf_set_option(result_bufnr, "modifiable", false)

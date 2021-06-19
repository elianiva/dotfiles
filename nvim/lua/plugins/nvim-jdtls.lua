local M = {}

M.plugin = {
  "mfussenegger/nvim-jdtls",
  ft = "java",
  after = "telescope.nvim",
  setup = function()
    vim.cmd [[
      augroup jdtls
      au!
      au FileType java lua require("plugins.nvim-jdtls").setup()
      augroup END
    ]]
  end,
  config = function()
    require("plugins.nvim-jdtls").config()
  end,
}

M.config = function()
  local ok, jdtls_ui = pcall(require, "jdtls.ui")
  if ok then
    local finders = require "telescope.finders"
    local sorters = require "telescope.sorters"
    local pickers = require "telescope.pickers"
    local actions = require "telescope.actions"

    jdtls_ui.pick_one_async = function(results, _, label_fn, cb)
      local opts = require("plugins.telescope").no_preview()
      pickers.new(opts, {
        prompt_title = "LSP Code Actions",
        finder = finders.new_table {
          results = results,
          entry_maker = function(line)
            return {
              valid = line ~= nil,
              value = line,
              ordinal = label_fn(line),
              display = label_fn(line),
            }
          end,
        },
        attach_mappings = function(prompt_bufnr)
          actions.select_default:replace(function()
            local selection = actions.get_selected_entry(prompt_bufnr)
            actions.close(prompt_bufnr)

            cb(selection.value)
          end)
          return true
        end,
        sorter = sorters.get_fzy_sorter(),
      }):find()
    end
  end
end

M.setup = function()
  require("jdtls").start_or_attach {
    cmd = { vim.env.HOME .. "/.scripts/run_jdtls" },
    on_attach = function()
      require("modules.lsp._mappings").lsp_mappings "jdtls"
    end,
  }
end

return M

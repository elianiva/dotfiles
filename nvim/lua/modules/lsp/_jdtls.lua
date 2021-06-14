local M = {}

local ok, jdtls_ui = pcall(require, "jdtls.ui")
if ok then
  local finders = require "telescope.finders"
  local sorters = require "telescope.sorters"
  local pickers = require "telescope.pickers"
  local actions = require "telescope.actions"
  local t = require "modules._telescope"

  jdtls_ui.pick_one_async = function(results, _, label_fn, cb)
    local opts = t.no_preview()
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

M.config = function()
  vim.cmd [[
    augroup jdtls
    au!
    au FileType java lua require"modules.lsp._jdtls".setup()
    augroup END
  ]]
end

M.setup = function()
  require("jdtls").start_or_attach {
    cmd = { vim.env.HOME .. "/.scripts/run_jdtls" },
    on_attach = function()
      require("modules.lsp._mappings").lsp_mappings "jdtls"
      require("lsp_signature").on_attach {
        bind = true,
        doc_lines = 2,
        hint_enable = false,
        handler_opts = {
          border = Util.borders,
        },
        max_height = 12,
        max_width = 120,
      }
    end,
  }
end

return M

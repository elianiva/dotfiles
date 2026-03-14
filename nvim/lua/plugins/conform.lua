return {
  "stevearc/conform.nvim",
  dependencies = { "mason.nvim" },
  lazy = true,
  cmd = "Format",
  config = function(_, opts)
    local conform = require("conform")

    conform.setup({
      formatters_by_ft = {
        lua = { "stylua" },
        javascript = { "oxfmt", lsp_format = "prefer" },
        javascriptreact = { "oxfmt", lsp_format = "prefer" },
        typescript = { "oxfmt", lsp_format = "prefer" },
        typescriptreact = { "oxfmt", lsp_format = "prefer" },
        json = { "oxfmt", lsp_format = "prefer" },
        jsonc = { "oxfmt", lsp_format = "prefer" },
        python = { "isort", "ruff" },
        php = { "pint" }
      }
    })

    vim.api.nvim_create_user_command("Format", function(args)
      local range = nil
      if args.count ~= -1 then
        local end_line = vim.api.nvim_buf_get_lines(0, args.line2 - 1, args.line2, true)[1]
        range = {
          start = { args.line1, 0 },
          ["end"] = { args.line2, end_line:len() },
        }
      end
      conform.format({
        async = true,
        lsp_format = "fallback",
        range = range,
        filter = function(client)
          return client.name ~= "tsserver" and
              client.name ~= "jsonls" and
              client.name ~= "sumneko_lua" and
              client.name ~= "typescript-tools"
        end
      })
    end, { range = true })
  end
}

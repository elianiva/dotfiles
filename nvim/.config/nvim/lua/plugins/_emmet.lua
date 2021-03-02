vim.g.user_emmet_install_global = 0
vim.g.user_emmet_leader_key = ","

vim.g.user_emmet_settings = {
  html = {
    snippets = {
      ["!"] = table.concat(
        {
          "<!DOCTYPE html>",
          "<html lang=\"en\">",
          "\t<head>",
          "\t\t<meta charset=\"utf-8\" />",
          "\t\t<meta name=\"viewport\" content=\"width=device-width,initial-scale=1.0\" />",
          "\t\t<title>${cursor}</title>",
          "\t</head>",
          "\t<body>",
          "\t\t<div>${child}</div>",
          "\t</body>",
          "</html>",
        },
        "\n"
      ),
    },
  },
}

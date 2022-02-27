vim.filetype.add({
  extension = {
    ejs = "html",
    hbs = "handlebars",
    svx = "markdown",
    mdx = "markdown",
    svelte = "svelte",
    rasi = "css",
    norg = "norg",
    patch = "patch",
  },
  filename = {
    [".prettierrc"] = "jsonc",
    [".eslintrc"] = "jsonc",
    ["tsconfig.json"] = "jsonc",
    ["jsconfig.json"] = "jsonc",
  },
})

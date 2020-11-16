local configs = require 'lspconfig/configs'
local util = require 'lspconfig/util'

local server_name = 'svelte'
local bin_name = 'svelteserver'

local installer = util.npm_installer {
  server_name = server_name;
  packages = { "typescript-language-server" };
  binaries = { bin_name };
}

configs[server_name] = {
  default_config = {
    cmd = {bin_name, '--stdio'};
    filetypes = {'svelte'};
    root_dir = util.root_pattern("package.json", ".git");
  };
  docs = {
    description = [[
https://github.com/sveltejs/language-tools/tree/master/packages/language-server

`svelte-language-server` can be installed via `:LspInstall svelte` or by yourself with `npm`:
```sh
npm install -g svelte-language-server
```
]];
    default_config = {
      root_dir = [[root_pattern("package.json", ".git")]];
    };
  }
}

configs[server_name].install = installer.install
configs[server_name].install_info = installer.info

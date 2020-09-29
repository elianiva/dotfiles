local configs = require 'nvim_lsp/configs'
local util = require 'nvim_lsp/util'
local lsp = vim.lsp

local server_name = "svelte"

configs[server_name] = {
  default_config = {
    cmd = {"/home/elianiva/.local/npm/bin/svelteserver", "--stdio"};
    filetypes = { "svelte" };
    root_dir = util.root_pattern(".git");
    log_level = lsp.protocol.MessageType.Warning;
    settings = {};
  };
}

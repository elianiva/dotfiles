{ config, pkgs, ... }:
{
  home.packages = with pkgs; [
    neovim-nightly
    gopls
    rust-analyzer
    sumneko-lua-language-server
  ];
}

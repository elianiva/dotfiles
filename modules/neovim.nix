{config, pkgs, home-manager, ...}:
{
  home.packages = with pkgs; [
    clang-tools
    stylua
    sumneko-lua-language-server
    gopls
  ];
}

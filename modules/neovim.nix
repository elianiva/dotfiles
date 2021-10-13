{ config, pkgs, home-manager, ... }:
{
  programs.java = {
    enable = true;
    package = pkgs.jdk11;
  };
  home.packages = with pkgs; [
    my.jdt-language-server
    clang-tools
    stylua
    sumneko-lua-language-server
    rust-analyzer
    gopls
    rnix-lsp
  ] ++ (with nodePackages; [
    pyright
    eslint_d
    typescript-language-server
    svelte-language-server
  ]);
}

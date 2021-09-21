{ config, pkgs, home-manager, ... }:
{
  programs.java = {
    enable = true;
    package = pkgs.jdk11;
  };
  home.packages = with pkgs; [
    my.jdt-language-server
    jdk11
    clang-tools
    stylua
    sumneko-lua-language-server
    rust-analyzer
    gopls
    rnix-lsp
  ] ++ (
    with nodePackages; [
      pyright
      svelte-language-server
      typescript-language-server
      eslint_d
    ]
  );
}

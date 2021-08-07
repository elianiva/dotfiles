{ config, pkgs, home-manager, ... }:
{
  home.packages = with pkgs; [
    my.jdt-language-server
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

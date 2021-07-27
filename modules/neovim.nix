{config, pkgs, home-manager, ...}:
{
  home.packages = with pkgs; [
    clang-tools
    stylua
    sumneko-lua-language-server
    rust-analyzer
    gopls
  ] ++ (with nodePackages; [
    pyright
    svelte-language-server
    typescript-language-server
  ]);
}

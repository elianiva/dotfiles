{config, pkgs, home-manager, ...}:
{
  home.packages = with pkgs; [
    delta
    gh
  ];
}

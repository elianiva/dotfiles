{ config, pkgs, ... }:
{
  home.packages = with pkgs; [
    tdesktop
    discord
  ];
}

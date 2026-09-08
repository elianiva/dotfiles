{ pkgs, config, ... }:
# Terminal configs are defined once in home-common.nix.
# Linux just needs the nixGL wrapper for ghostty (GPU on non-NixOS).
{
  home.packages = [
    (config.lib.nixGL.wrap pkgs.ghostty)
  ];
}

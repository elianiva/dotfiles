{ pkgs, config, lib, ... }:
# Terminal configs are defined once in home-common.nix.
# x86_64 needs nixGL wrapper for GPU on non-NixOS; aarch64/Asahi uses host Mesa directly.
{
  home.packages =
    if pkgs.stdenv.hostPlatform.isAarch64 then
      [ pkgs.ghostty ]
    else
      [ (config.lib.nixGL.wrap pkgs.ghostty) ];
}

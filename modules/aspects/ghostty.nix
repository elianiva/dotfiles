# ghostty: config symlink everywhere, an extra Application Support symlink on
# macOS, and a nixGL-wrapped package on x86_64 Linux.
{ den, ... }:
{
  den.aspects.ghostty.homeManager =
    {
      config,
      pkgs,
      lib,
      ...
    }:
    let
      link = config.lib.file.mkOutOfStoreSymlink;
      dotfiles = "${config.home.homeDirectory}/.dotfiles";
    in
    {
      xdg.configFile."ghostty" = {
        source = link "${dotfiles}/ghostty";
        recursive = true;
      };
    }
    // lib.optionalAttrs pkgs.stdenv.hostPlatform.isDarwin {
      home.file."Library/Application Support/com.mitchellh.ghostty" = {
        source = link "${dotfiles}/ghostty";
        recursive = true;
      };
    }
    // lib.optionalAttrs pkgs.stdenv.hostPlatform.isLinux {
      # x86_64 needs the nixGL wrapper for GPU on non-NixOS; aarch64/Asahi uses
      # host Mesa directly.
      home.packages =
        if pkgs.stdenv.hostPlatform.isAarch64 then
          [ pkgs.ghostty ]
        else
          [ (config.lib.nixGL.wrap pkgs.ghostty) ];
    };
}

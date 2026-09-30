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
    # The platform branches stay nested in `home.file` / `home.packages`: a
    # top-level `// lib.optionalAttrs ...` would force `pkgs` while the module
    # is being applied, and home-manager resolves that through
    # `_module.args.pkgs`, which needs the config currently being built.
    {
      xdg.configFile."ghostty" = {
        source = link "${dotfiles}/ghostty";
        recursive = true;
      };

      home.file = lib.optionalAttrs pkgs.stdenv.hostPlatform.isDarwin {
        "Library/Application Support/com.mitchellh.ghostty" = {
          source = link "${dotfiles}/ghostty";
          recursive = true;
        };
      };

      # x86_64 needs the nixGL wrapper for GPU on non-NixOS; aarch64/Asahi uses
      # host Mesa directly.
      home.packages = lib.optionals pkgs.stdenv.hostPlatform.isLinux (
        if pkgs.stdenv.hostPlatform.isAarch64 then
          [ pkgs.ghostty ]
        else
          [ (config.lib.nixGL.wrap pkgs.ghostty) ]
      );
    };
}

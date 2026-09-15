# nushell reads its config from a different place on macOS (Application
# Support) than on Linux (XDG). One aspect, both platforms.
{ den, ... }:
{
  den.aspects.nushell.homeManager =
    {
      config,
      pkgs,
      lib,
      ...
    }:
    let
      link = config.lib.file.mkOutOfStoreSymlink;
      dotfiles = "${config.home.homeDirectory}/.dotfiles";
      isDarwin = pkgs.stdenv.hostPlatform.isDarwin;
    in
    {
      # nushell produces its own config file which causes conflict
      xdg.configFile = lib.optionalAttrs (!isDarwin) {
        "nushell/config.nu".enable = false;
        "nushell/env.nu".enable = false;
      };

      home.file =
        lib.optionalAttrs isDarwin {
          "Library/Application Support/nushell" = {
            source = link "${dotfiles}/nushell";
            recursive = true;
          };
        }
        // lib.optionalAttrs (!isDarwin) {
          ".config/nushell" = {
            source = link "${dotfiles}/nushell";
            recursive = true;
          };
        };
    };
}

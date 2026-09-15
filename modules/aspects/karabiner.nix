# karabiner-elements config — macOS only.
{ den, ... }:
{
  den.aspects.karabiner.homeManager =
    {
      config,
      pkgs,
      lib,
      ...
    }:
    let
      link = config.lib.file.mkOutOfStoreSymlink;
    in
    lib.optionalAttrs pkgs.stdenv.hostPlatform.isDarwin {
      xdg.configFile."karabiner/karabiner.json".source =
        link "${config.home.homeDirectory}/.dotfiles/karabiner/karabiner.json";
    };
}

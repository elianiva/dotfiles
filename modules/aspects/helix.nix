{ den, ... }:
{
  den.aspects.helix.homeManager =
    { config, ... }:
    let
      link = config.lib.file.mkOutOfStoreSymlink;
    in
    {
      xdg.configFile."helix" = {
        source = link "${config.home.homeDirectory}/.dotfiles/helix";
        recursive = true;
      };
    };
}

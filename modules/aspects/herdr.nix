{ den, ... }:
{
  den.aspects.herdr.homeManager =
    { config, ... }:
    let
      link = config.lib.file.mkOutOfStoreSymlink;
    in
    {
      xdg.configFile."herdr/config.toml".source =
        link "${config.home.homeDirectory}/.dotfiles/herdr/config.toml";
    };
}

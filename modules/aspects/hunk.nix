{ den, ... }:
{
  den.aspects.hunk.homeManager =
    { config, ... }:
    let
      link = config.lib.file.mkOutOfStoreSymlink;
    in
    {
      xdg.configFile."hunk/config.toml".source =
        link "${config.home.homeDirectory}/.dotfiles/hunk/config.toml";
    };
}

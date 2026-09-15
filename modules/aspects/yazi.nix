{ den, ... }:
{
  den.aspects.yazi.homeManager =
    { config, ... }:
    let
      link = config.lib.file.mkOutOfStoreSymlink;
    in
    {
      xdg.configFile."yazi" = {
        source = link "${config.home.homeDirectory}/.dotfiles/yazi";
        recursive = true;
      };
    };
}

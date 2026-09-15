{ den, ... }:
{
  den.aspects.jjui.homeManager =
    { config, ... }:
    let
      link = config.lib.file.mkOutOfStoreSymlink;
    in
    {
      xdg.configFile."jjui" = {
        source = link "${config.home.homeDirectory}/.dotfiles/jjui";
        recursive = true;
      };
    };
}

{ den, ... }:
{
  den.aspects.fastfetch.homeManager =
    { config, ... }:
    let
      link = config.lib.file.mkOutOfStoreSymlink;
    in
    {
      xdg.configFile."fastfetch" = {
        source = link "${config.home.homeDirectory}/.dotfiles/fastfetch";
        recursive = true;
      };
    };
}

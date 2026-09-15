{ den, ... }:
{
  den.aspects.zellij.homeManager =
    { config, ... }:
    let
      link = config.lib.file.mkOutOfStoreSymlink;
    in
    {
      xdg.configFile."zellij" = {
        source = link "${config.home.homeDirectory}/.dotfiles/zellij";
        recursive = true;
      };
    };
}

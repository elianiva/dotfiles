{ den, ... }:
{
  den.aspects.kitty.homeManager =
    { config, ... }:
    let
      link = config.lib.file.mkOutOfStoreSymlink;
      dotfiles = "${config.home.homeDirectory}/.dotfiles";
    in
    {
      xdg.configFile = {
        "kitty/kitty.conf".enable = false;

        "kitty" = {
          source = link "${dotfiles}/kitty";
          recursive = true;
        };
      };
    };
}

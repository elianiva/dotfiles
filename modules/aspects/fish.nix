{ den, ... }:
{
  den.aspects.fish.homeManager =
    { config, ... }:
    let
      link = config.lib.file.mkOutOfStoreSymlink;
      dotfiles = "${config.home.homeDirectory}/.dotfiles";
    in
    {
      xdg.configFile = {
        # fish produces its own config file which causes conflict
        "fish/config.fish".enable = false;

        "fish" = {
          source = link "${dotfiles}/fish";
          recursive = true;
        };
      };
    };
}

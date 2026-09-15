{ den, ... }:
{
  den.aspects.wezterm.homeManager =
    { config, ... }:
    let
      link = config.lib.file.mkOutOfStoreSymlink;
      dotfiles = "${config.home.homeDirectory}/.dotfiles";
    in
    {
      xdg.configFile = {
        "wezterm/wezterm.lua".enable = false;

        "wezterm" = {
          source = link "${dotfiles}/wezterm";
          recursive = true;
        };
      };
    };
}

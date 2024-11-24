{ pkgs, config, ... }:
let
  link = config.lib.file.mkOutOfStoreSymlink;
  dotfiles = "${config.home.homeDirectory}/.dotfiles";
in
{
  programs.wezterm = {
    enable = true;
    package = config.lib.nixGL.wrap pkgs.wezterm;
  };

  # NOTE(elianiva): as a backup in case wezterm got borked
  programs.kitty = {
    enable = true;
    package = config.lib.nixGL.wrap pkgs.kitty;
  };

  # terminals produces their own config file which causes conflict
  xdg.configFile."wezterm/wezterm.lua".enable = false;
  xdg.configFile."kitty/kitty.conf".enable = false;

  # I don't want to rebuild everytime i change these configs
  home.file = {
    ".config/wezterm" = {
      source = link "${dotfiles}/wezterm";
      recursive = true;
    };
    ".config/kitty" = {
      source = link "${dotfiles}/kitty";
      recursive = true;
    };
  };
}

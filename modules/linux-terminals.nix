{ pkgs, config, inputs, ... }:
let
  link = config.lib.file.mkOutOfStoreSymlink;
  dotfiles = "${config.home.homeDirectory}/.dotfiles";
in
{
  home.packages = [
    (config.lib.nixGL.wrap inputs.ghostty.packages."${pkgs.system}".default)
  ];

  # NOTE(elianiva): as a backup in case ghostty got borked
  programs.kitty = {
    enable = true;
    package = (config.lib.nixGL.wrap inputs.kitty.packages."${pkgs.system}".default);
  };

  # terminals produces their own config file which causes conflict
  xdg.configFile = {
    "wezterm/wezterm.lua".enable = false;
    "kitty/kitty.conf".enable = false;

    "wezterm" = {
      source = link "${dotfiles}/wezterm";
      recursive = true;
    };
    "kitty" = {
      source = link "${dotfiles}/kitty";
      recursive = true;
    };
    "ghostty" = {
      source = link "${dotfiles}/ghostty";
      recursive = true;
    };
  };
}

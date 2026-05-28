{ pkgs, config, inputs, identity, ... }:
let
  inherit (import ./helpers.nix { inherit config; }) link;
  inherit (identity) dotfiles;
in
{
  home.packages = [
    (config.lib.nixGL.wrap pkgs.ghostty)
  ];

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

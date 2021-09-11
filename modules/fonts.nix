{ config, pkgs, home-manager, ... }:
let
  link = path:
    config.lib.file.mkOutOfStoreSymlink
      "${config.home.homeDirectory}/Repos/dotfiles/${path}";
in
{
  home.packages = with pkgs; [
    inter
    mplus-outline-fonts
    open-sans
    (nerdfonts.override { fonts = [ "JetBrainsMono" ]; })
  ];

  fonts.fontconfig.enable = true;

  home = {
    file = {
      ".config/fontconfig/conf.d/20-japanese-preferred.conf" = {
        source = link "config/fontconfig/conf.d/20-japanese-preferred.conf";
      };
    };
  };
}

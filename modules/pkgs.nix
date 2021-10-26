{ config, pkgs, home-manager, ... }:
{
  home.packages = with pkgs; [
    my.awesome-git
    sxiv
    picom
    zathura
    transmission-gtk
    (
      pkgs.symlinkJoin {
        name = "rofi";
        paths = [
          (writeShellScriptBin "rofi" ''LANG=C ${pkgs.rofi}/bin/rofi "$@"'')
          pkgs.rofi
        ];
      }
    )
    xclip
    gcr # for pinentry-gnome3
    fishPlugins.foreign-env # `fenv`
  ];
  services.clipmenu.enable = true;
  programs.man.enable = false;
  home.extraOutputsToInstall = [ "man" ];
}

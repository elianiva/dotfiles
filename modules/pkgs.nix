{ config, pkgs, home-manager, ... }:
{
  home.packages = with pkgs; [
    fishPlugins.foreign-env # `fenv`
    gcr # for pinentry-gnome3
    my.awesome-git
    picom
    sxiv
    transmission-gtk
    xclip
    zathura
    (
      pkgs.symlinkJoin {
        name = "rofi";
        paths = [
          (writeShellScriptBin "rofi" ''LANG=C ${pkgs.rofi}/bin/rofi "$@"'')
          pkgs.rofi
        ];
      }
    )
  ];
  services.clipmenu.enable = true;
  programs.man.enable = false;
  home.extraOutputsToInstall = [ "man" ];
}

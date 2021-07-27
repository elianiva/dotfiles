{config, pkgs, home-manager, ...}:
{
  home.packages = with pkgs; [
    sxiv
    picom
    zathura
    (pkgs.symlinkJoin {
      name = "rofi";
      paths = [
        (writeShellScriptBin "rofi" ''LANG=C ${pkgs.rofi}/bin/rofi "$@"'')
        pkgs.rofi
      ];
    })
    xclip
    awesome-git # this one comes from the overlay
    gcr # for pinentry-gnome3
  ];
  services.clipmenu.enable = true;
  programs.man.enable = false;
  home.extraOutputsToInstall = [ "man" ];
}

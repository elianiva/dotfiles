{config, pkgs, home-manager, ...}:
{
  home.packages = with pkgs; [
    imv
    picom
    zathura
    simplescreenrecorder
    flameshot
    (writeShellScriptBin "rofi" ''LANG=C ${pkgs.rofi}/bin/rofi "$@"'')
    xclip
    awesome-git # this one comes from the overlay
  ];
  services.clipmenu.enable = true;
}

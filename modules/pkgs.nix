{config, pkgs, home-manager, ...}:
{
  home.packages = with pkgs; [
    picom
    zathura
    simplescreenrecorder
    flameshot
    rofi
    xclip
    awesome-git # this one comes from the custom overlay
  ];
  services.clipmenu.enable = true;
}

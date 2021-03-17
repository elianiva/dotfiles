{ config, pkgs, ... }:
{
  programs.sway = {
    enable = true;
    wrapperFeatures.gtk = true; # so that gtk works properly
    extraPackages = with pkgs; [
      wl-clipboard # clipboard
      wf-recorder # screen recorder
      grim # screenshot
      slurp # area selection
      waybar # statusbar
      wofi # app launcher
      mako # notification daemon
      alacritty # Alacritty is the default terminal in the config
    ];
  };

  # qt5ct compat
  programs.qt5ct.enable = true;
}


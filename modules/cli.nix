{ config, pkgs, libs, ... }:
{
  home.packages = with pkgs; [
    acpi
    bat
    exa
    fd
    ffmpeg
    htop
    imagemagick
    jq
    lf
    light
    lm_sensors
    neofetch
    pulsemixer
    ripgrep
    skim
    slop
    starship
    tmux
    unzip
    xh
    xorg.xset
    wget
    # xorg.setxkbmap
  ];

  programs.bat = {
    enable = true;
    config = {
      theme = "base16";
      style = "plain";
    };
  };

  programs.htop = {
    enable = true;
    settings = {
      enableMouse = true;
      highlightBaseName = true;
      highlightThreads = true;
      showCpuFrequency = true;
    };
  };
}

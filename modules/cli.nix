{ config, pkgs, libs, ... }:
{
  home.packages = with pkgs; [
    acpi
    aria
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
    # nix
    p7zip
    playerctl
    pulsemixer
    ripgrep
    skim
    slop
    starship
    tealdeer
    tmux
    unzip
    unrar
    wget
    xh
    xorg.xset
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

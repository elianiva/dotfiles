{ config, pkgs, libs, ... }:
{
  home.packages = with pkgs; [
    acpi
    bat
    exa
    fd
    htop
    jq
    lf
    light
    lm_sensors
    neofetch
    pulsemixer
    ripgrep
    skim
    starship
    tmux
    xh
    xorg.setxkbmap
    xorg.xset
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

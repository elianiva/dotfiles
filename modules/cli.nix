{ config, pkgs, libs, ... }:
{
  home.packages = with pkgs; [
    bat
    exa
    fd
    skim
    htop
    jq
    lf
    pulsemixer
    ripgrep
    starship
    tmux
    xh
    neofetch
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

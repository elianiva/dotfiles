{ config, pkgs, ... }:
{
  programs.home-manager = {
    enable = true;
  };

  home.packages = with pkgs; [
    firefox # my preferred browser
    google-chrome-dev # alternative
  ];
}


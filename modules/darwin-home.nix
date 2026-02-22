{ lib, pkgs, inputs, flakePkgs, config, ... }:
let
  appConfig = "Library/Application Support";
  link = config.lib.file.mkOutOfStoreSymlink;
  dotfiles = "${config.home.homeDirectory}/.dotfiles";
in
{
  imports = [ ./home-common.nix ];

  programs.direnv = {
    enableFishIntegration = false;
    enableBashIntegration = false;
    enableNushellIntegration = true;
    enableZshIntegration = false;
  };

  home.file = {
    "${appConfig}/nushell" = {
      source = link "${dotfiles}/nushell";
      recursive = true;
    };
    "${appConfig}/com.mitchellh.ghostty" = {
      source = link "${dotfiles}/ghostty";
      recursive = true;
    };
  };
}
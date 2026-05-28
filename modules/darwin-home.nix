{ lib, pkgs, inputs, config, identity, ... }:
let
  inherit (import ./helpers.nix { inherit config; }) link;
  inherit (identity) dotfiles;
  appConfig = "Library/Application Support";
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
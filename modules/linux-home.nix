{ lib, pkgs, inputs, flakePkgs, fenix, config, identity, ... }:
let
  inherit (import ./helpers.nix { inherit config; }) link;
  inherit (identity) dotfiles;
  nixGLIntel = inputs.nixGL.packages."${pkgs.system}".nixGLIntel;
in
{
  imports = [ ./home-common.nix ];

  targets.genericLinux.enable = true;

  # allow unfree packages
  nixpkgs.config.allowUnfree = true;

  targets.genericLinux.nixGL = {
    packages = inputs.nixGL.packages;
    defaultWrapper = "mesa";
    installScripts = [ "mesa" ];
  };

  # nix is managed by home-manager on Linux (unlike macOS where nix-darwin handles it)
  nix = {
    enable = true;
    package = pkgs.nixVersions.stable;
  };

  home = {
    packages = import ./linux-packages.nix { inherit pkgs flakePkgs fenix nixGLIntel; };

    username = identity.username;
    homeDirectory = "/home/${identity.username}";
  };

  # enable fontconfig
  fonts.fontconfig = {
    enable = true;
    defaultFonts = {
      monospace = [ "JetBrainsMono" ];
      sansSerif = [ "Inter" ];
    };
  };

  programs.nushell.enable = true;

  # nushell produces its own config file which causes conflict
  xdg.configFile = {
    "nushell/config.nu".enable = false;
    "nushell/env.nu".enable = false;
  };

  home.file.".config/nushell" = {
    source = link "${dotfiles}/nushell";
    recursive = true;
  };
}

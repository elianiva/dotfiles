{ lib, pkgs, inputs, flakePkgs, config, ... }:
let
  nixGLIntel = inputs.nixGL.packages."${pkgs.system}".nixGLIntel;
  link = config.lib.file.mkOutOfStoreSymlink;
  dotfiles = "${config.home.homeDirectory}/.dotfiles";
in
{
  imports = [ ./home-common.nix ];

  targets.genericLinux.enable = true;

  # allow unfree packages
  nixpkgs.config.allowUnfree = true;

  nixGL.packages = inputs.nixGL.packages;
  nixGL.defaultWrapper = "mesa";
  nixGL.installScripts = [ "mesa" ];

  nix = {
    enable = true;
    package = pkgs.nixVersions.stable;
  };

  home = {
    packages = import ./linux-packages.nix { inherit pkgs flakePkgs; };

    username = "elianiva";
    homeDirectory = "/home/elianiva";

    sessionVariables = {
      # Make it possible to handle "xterm-kitty" in SSH remotes or lima guest VM with tiny filesize and setups. See GH-932
      TERMINFO_DIRS = "${pkgs.kitty.terminfo}/share/terminfo";
    };
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
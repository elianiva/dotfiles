{ lib, pkgs, inputs, flakePkgs, config, identity, ioshelfka, ... }:
let
  inherit (import ./helpers.nix { inherit config; }) link;
  inherit (identity) dotfiles;
  nixGLIntel = inputs.nixGL.packages."${pkgs.stdenv.hostPlatform.system}".nixGLIntel;
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

    gc = {
      automatic = true;
      frequency = "weekly";
      options = "--delete-older-than 7d";
    };
    settings.auto-optimise-store = true;
  };

  home = {
    packages =
      (import ./packages.nix { inherit pkgs flakePkgs; })
      ++ (import ./rust.nix { inherit pkgs; })
      ++ (import ./linux-packages.nix { inherit pkgs nixGLIntel; })
      ++ (import ./fonts.nix { inherit pkgs ioshelfka; });

    username = identity.username;
    homeDirectory = identity.homeDir;
  };

  # enable fontconfig
  fonts.fontconfig = {
    enable = true;
    defaultFonts = {
      monospace = [ "JetBrainsMono" ];
      sansSerif = [ "Inter" ];
    };
  };

  # nushell is provided via shared packages (packages.nix) and configured
  # via home.file symlink below — no need for programs.nushell.enable here
  # (kept in sync with darwin-home which also links config manually).
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

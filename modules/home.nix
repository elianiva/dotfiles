{ lib, pkgs, inputs, config, ... }:
let
  nixGLIntel = inputs.nixGL.packages."${pkgs.system}".nixGLIntel;
  link = config.lib.file.mkOutOfStoreSymlink;
  dotfiles = "${config.home.homeDirectory}/.dotfiles";
in
{
  targets.genericLinux.enable = true;

  # allow unfree packages
  nixpkgs = {
    config = {
      allowUnfree = true;
      allowUnfreePredicate = (_: true);
    };
  };

  imports = [
    # todo: remove when https://github.com/nix-community/home-manager/pull/5355 gets merged:
    (builtins.fetchurl {
      url = "https://raw.githubusercontent.com/Smona/home-manager/nixgl-compat/modules/misc/nixgl.nix";
      sha256 = "sha256:1krclaga358k3swz2n5wbni1b2r7mcxdzr6d7im6b66w3sbpvnb3";
    })
  ];

  nixGL.packages = inputs.nixGL.packages;
  nixGL.defaultWrapper = "mesa";
  nixGL.installScripts = [ "mesa" ];

  nix = {
    enable = true;
    package = pkgs.nixFlakes;
    settings = {
      substituters = [
        "https://cache.nixos.org"

        "https://nix-community.cachix.org"
      ];

      trusted-public-keys = [
        "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="

        "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
      ];
    };
  };

  home = {
    packages = with pkgs; [
      # cli tools
      dust
      lazygit
      ripgrep
      fd
      btop
      rclone
      yt-dlp
      yazi # tui file manager
      pass
      yq

      # docments
      typst

      # editor / workspace management
      zellij
      neovim

      # git related
      git-filter-repo # useful to remove accidentally committed secrets
      delta

      # rust
      rustc
      cargo

      # devenv / direnv
      devenv
      direnv

      # php (yikes, but this is needed for phpactor)
      php

      # pinentry
      pinentry-gnome3

      # terminals, nixgl is needed to access intel drivers from non-nixos environments
      nixGLIntel

      # fonts
      jetbrains-mono
      inter
    ];

    username = "elianiva";
    homeDirectory = "/home/elianiva";

    stateVersion = "24.05";
  };

  # enable fontconfig
  fonts.fontconfig = {
    enable = true;
    defaultFonts = {
      monospace = [ "JetBrainsMono" ];
      sansSerif = [ "Inter" ];
    };
  };

  programs = {
    # let home manager manages itself
    home-manager.enable = true;

    bat = {
      enable = true;
      config = {
        theme = "base16";
        "italic-text" = "always";
        style = "numbers";
      };
    };

    fish.enable = true;

    starship = {
      enable = true;
      settings = {
        add_newline = true;
        directory.truncation_length = 8;
        git_status.format = "([\($all_status$ahead_behind\)]($style) )";
        git_status.ahead = "⇡$\{count\}";
        git_status.behind = "⇣$\{count\}";
        git_status.diverged = "⇕⇡$\{ahead_count\} ⇣$\{behind_count\}";
        package.disabled = true;
        golang.format = "via [ $version](bold blue) ";
        gcloud.disabled = true;
      };
    };
  };

  # wezterm produces its own wezterm.lua file which causes conflict
  xdg.configFile."wezterm/wezterm.lua".enable = false;
  # fish produces its own wezterm.lua file which causes conflict
  xdg.configFile."fish/config.fish".enable = false;

  # I don't want to rebuild everytime i change these configs
  home.file = {
    ".profile".source = link "${dotfiles}/misc/.profile";
    ".bashrc".source = link "${dotfiles}/misc/.bashrc";
    ".config/zellij" = {
      source = link "${dotfiles}/zellij";
      recursive = true;
    };
    ".config/nvim" = {
      source = link "${dotfiles}/nvim";
      recursive = true;
    };
    ".config/fish" = {
      source = link "${dotfiles}/fish";
      recursive = true;
    };
  };
}

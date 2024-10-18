{ lib, pkgs, inputs, config, ... }:
let
  nixGLIntel = inputs.nixGL.packages."${pkgs.system}".nixGLIntel;
  link = config.lib.file.mkOutOfStoreSymlink;
  dotfiles = "${config.home.homeDirectory}/.dotfiles";
in
{
  targets.genericLinux.enable = true;

  imports = [
    # todo: remove when https://github.com/nix-community/home-manager/pull/5355 gets merged:
    (builtins.fetchurl {
      url = "https://raw.githubusercontent.com/Smona/home-manager/nixgl-compat/modules/misc/nixgl.nix";
      sha256 = "01dkfr9wq3ib5hlyq9zq662mp0jl42fw3f6gd2qgdf8l8ia78j7i";
    })
  ];

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
      lf # tui file manager

      # editor / workspace management
      zellij
      neovim

      # git related
      git-filter-repo # useful to remove accidentally committed secrets

      rustc
      cargo

      # terminals, nixgl is needed to access intel drivers from non-nixos environments
      (config.lib.nixGL.wrap pkgs.wezterm)
      (config.lib.nixGL.wrap pkgs.kitty)
    ];

    username = "elianiva";
    homeDirectory = "/home/elianiva";

    stateVersion = "24.05";
  };

  nixGL.prefix = "${nixGLIntel}/bin/nixGLIntel";

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

    wezterm = {
      enable = true;
      package = config.lib.nixGL.wrap pkgs.wezterm;
    };

    # NOTE(elianiva): as a backup in case wezterm got borked
    kitty = {
      enable = true;
      package = config.lib.nixGL.wrap pkgs.kitty;
      font = {
        name = "JetBrainsMono Nerd Font";
        size = 12;
      };
      settings = {
        adjust_line_height = "140%";
        box_drawing_scale = "0.001, 0.5, 1, 1.75";

        enable_audio_bell = "no";
        window_padding_width = 2;
        background_opacity = 1;
        tab_bar_style = "fade";
        allow_remote_control = "yes";
        hide_window_decorations = "no";
      };
      keybindings = {
        "ctrl+shift+w" = "no-op";
        "alt+shift+k" = "change_font_size all +1.0";
        "alt+shift+j" = "change_font_size all -1.0";
        "alt+v" = "paste_from_clipboard";
        "alt+c" = "copy_to_clipboard";
        "alt+k" = "combine : send_text application k : scroll_line_up";
        "alt+j" = "combine : send_text application j : scroll_line_down";
        "alt+u" = "scroll_page_up";
        "alt+d" = "scroll_page_down";
        "kitty_mod+t" = "new_tab_with_cwd";
        "alt+space" = "no_op";
        "alt+1" = "goto_tab 1";
        "alt+2" = "goto_tab 2";
        "alt+3" = "goto_tab 3";
        "alt+4" = "goto_tab 4";
        "alt+5" = "goto_tab 5";
        "alt+6" = "goto_tab 6";
        "alt+n" = "next_tab";
        "alt+p" = "previous_tab";
      };
    };
  };

  # wezterm produces its own wezterm.lua file which causes conflict
  xdg.configFile."wezterm/wezterm.lua".enable = false;

  # I don't want to rebuild everytime i change these configs
  home.file = {
    ".profile".source = link "${dotfiles}/misc/.profile";
    ".config/zellij" = {
      source = link "${dotfiles}/zellij";
      recursive = true;
    };
    ".config/wezterm" = {
      source = link "${dotfiles}/wezterm";
      recursive = true;
    };
    ".config/nvim" = {
      source = link "${dotfiles}/nvim";
      recursive = true;
    };
  };
}

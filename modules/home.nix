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

  nixGL.packages = inputs.nixGL.packages;
  nixGL.defaultWrapper = "mesa";
  nixGL.installScripts = [ "mesa" ];

  nix = {
    enable = true;
    package = pkgs.nixVersions.stable;
  };

  home = {
    packages = with pkgs; [
      # cli tools
      dust
      ripgrep
      fd
      rclone
      yt-dlp
      yazi # tui file manager
      pass
      yq
      zoxide # switch between multiple projects faster
      eza # better ls

      lazydocker # manage docker stuff

      typst # documents

      zellij
      neovim

      # git related
      git-filter-repo # useful to remove accidentally committed secrets
      delta
      difftastic

      # rust
      rustc
      cargo

      # devenv / direnv
      devenv
      direnv

      # pinentry
      pinentry-gnome3

      # nixgl is needed to access intel drivers from non-nixos environments
      nixGLIntel

      # fonts
      monaspace
      inter
      lora

      nerd-fonts.jetbrains-mono

      obsidian
    ];

    username = "elianiva";
    homeDirectory = "/home/elianiva";

    # don't change this, see: https://nix-community.github.io/home-manager/
    stateVersion = "24.05";

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

    btop = {
      enable = true;
      settings = {
        color_theme = "TTY";
      };
    };

    fzf = {
      enable = true;
      # https://github.com/junegunn/fzf/blob/d579e335b5aa30e98a2ec046cb782bbb02bc28ad/README.md#respecting-gitignore
      defaultCommand = "${pkgs.fd}/bin/fd --type f --strip-cwd-prefix --hidden --follow --exclude .git";
      defaultOptions = [
        # --walker*: Default file filtering will be changed by this option if FZF_DEFAULT_COMMAND is not set: https://github.com/junegunn/fzf/pull/3649/files
        "--walker-skip '.git,node_modules,.direnv,vendor,dist'"
      ];
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

  # fish produces its own config file which causes conflict
  xdg.configFile."fish/config.fish".enable = false;

  # I don't want to rebuild everytime i change these configs
  home.file = {
    ".profile".source = link "${dotfiles}/misc/.profile";
    ".bashrc".source = link "${dotfiles}/misc/.bashrc";
    ".config/fastfetch" = {
      source = link "${dotfiles}/fastfetch";
      recursive = true;
    };
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

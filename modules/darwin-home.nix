{ lib, pkgs, inputs, flakePkgs, config, ... }:
let
  user = "elianiva";
  link = config.lib.file.mkOutOfStoreSymlink;
  dotfiles = "${config.home.homeDirectory}/.dotfiles";
in
{
  home = {
    # don't change this, see: https://nix-community.github.io/home-manager/
    stateVersion = "24.05";
  };

  programs = {
    # let home manager manages itself
    home-manager.enable = true;

    # nix-direnv
    direnv = {
      enable = true;
      nix-direnv.enable = true;
      enableFishIntegration = false;
      enableBashIntegration = false;
      enableNushellIntegration = true;
      enableZshIntegration = false;
      stdlib = builtins.readFile ../direnv/direnvrc;

      package = pkgs.direnv.overrideAttrs (old: {
        doCheck = false;
      });
    };

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

    # completion
    carapace.enable = true;
    carapace.enableNushellIntegration = true;

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

  home.file = {
    "Library/Application Support/nushell" = {
      source = link "${dotfiles}/nushell";
      recursive = true;
    };
    "Library/Application Support/com.mitchellh.ghostty" = {
      source = link "${dotfiles}/ghostty";
      recursive = true;
    };
  };

  xdg.configFile = {
    # fish produces its own config file which causes conflict
    "fish/config.fish".enable = false;
    "fastfetch" = {
      source = link "${dotfiles}/fastfetch";
      recursive = true;
    };
    "zellij" = {
      source = link "${dotfiles}/zellij";
      recursive = true;
    };
    "nvim" = {
      source = link "${dotfiles}/nvim";
      recursive = true;
    };
    "helix" = {
      source = link "${dotfiles}/helix";
      recursive = true;
    };
    "fish" = {
      source = link "${dotfiles}/fish";
      recursive = true;
    };
    "yazi" = {
      source = link "${dotfiles}/yazi";
      recursive = true;
    };
    "jjui" = {
      source = link "${dotfiles}/jjui";
      recursive = true;
    };
    "opencode/opencode.json" = {
      source = link "${dotfiles}/opencode/opencode.json";
    };
    "opencode/commands" = {
      source = link "${dotfiles}/opencode/commands";
      recursive = true;
    };
    "opencode/AGENTS.md" = {
      source = link "${dotfiles}/agents/AGENTS.md";
    };
    "opencode/skills" = {
      source = link "${dotfiles}/agents/skills";
      recursive = true;
    };
  };

  # I don't want to rebuild everytime i change these configs
  home.file = {
    ".profile".source = link "${dotfiles}/misc/.profile";
    ".bashrc".source = link "${dotfiles}/misc/.bashrc";
  };
}

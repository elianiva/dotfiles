{ pkgs, config, lib, identity, ... }:
let
  inherit (import ./helpers.nix { inherit config; }) link;
  inherit (identity) dotfiles;
  pi = ".pi/agent";
  vpPkgs = import ./vp-global-packages.nix;
  omp = ".omp/agent";
in
{
  home = {
    # don't change this, see: https://nix-community.github.io/home-manager/
    stateVersion = "25.11";
  };

  # Bootstrap vp and install missing global packages on activation
  home.activation.vp-global-packages = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    vp="$HOME/.vite-plus/bin/vp"
    if [[ ! -f "$vp" ]]; then
      $DRY_RUN_CMD curl -fsSL https://vite.plus | bash
    fi
    if [[ -f "$vp" ]]; then
      installed=$("$vp" list -g --json 2>/dev/null | sed -n 's/.*"name": "\([^"]*\)".*/\1/p')
      missing=""
      for pkg in ${builtins.toString vpPkgs.globalPackages}; do
        if ! echo "$installed" | grep -qxF "$pkg"; then
          missing="$missing $pkg"
        fi
      done
      if [[ -n "$missing" ]]; then
        $DRY_RUN_CMD "$vp" install -g $missing
      fi
    fi
  '';

  programs = {
    # let home manager manages itself
    home-manager.enable = true;

    # nix-direnv
    direnv = {
      enable = true;
      nix-direnv.enable = true;
      stdlib = builtins.readFile ../direnv/direnvrc;

      package = pkgs.direnv.overrideAttrs (old: {
        doCheck = false;
      });
    };

    bat = {
      enable = true;
      config = {
        theme = "Catppuccin Latte";
        "italic-text" = "always";
        style = "numbers";
      };
    };

    btop = {
      enable = true;
      settings = {
        color_theme = "paper";
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

    zoxide = {
      enable = true;
      enableNushellIntegration = false; # managed manually in nushell/zoxide.nu
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
        # custom.jj = {
        #   when = "jj-starship detect";
        #   shell = ["jj-starship"];
        #   format = "$output ";
        # };
      };
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
    "herdr/config.toml".source = link "${dotfiles}/herdr/config.toml";
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
    "hunk/config.toml".source = link "${dotfiles}/hunk/config.toml";

    # opencode configs
    "opencode/opencode.json".source = link "${dotfiles}/agents/opencode/opencode.json";
    "opencode/AGENTS.md".source = link "${dotfiles}/agents/AGENTS.md";
    "opencode/skills" = {
      source = link "${dotfiles}/agents/skills";
      recursive = true;
    };
  };

  home.file = {
    # shell configs
    ".profile".source = link "${dotfiles}/misc/.profile";
    ".bashrc".source = link "${dotfiles}/misc/.bashrc";

    # pi coding agent related configs
    "${pi}/AGENTS.md".source = link "${dotfiles}/agents/AGENTS.md";
    "${pi}/settings.json".source = link "${dotfiles}/agents/pi/settings.json";
    "${pi}/models.json".source = link "${dotfiles}/agents/pi/models.json";
    "${pi}/package.json".source = link "${dotfiles}/agents/pi/package.json";
    "${pi}/skills" = {
      source = link "${dotfiles}/agents/skills";
      recursive = true;
    };
    "${pi}/extensions" = {
      source = link "${dotfiles}/agents/pi/extensions";
      recursive = true;
    };
    "${pi}/themes" = {
      source = link "${dotfiles}/agents/pi/themes";
      recursive = true;
    };
    # omp coding agent related configs
    "${omp}/AGENTS.md".source = link "${dotfiles}/agents/AGENTS.md";
    "${omp}/skills" = {
      source = link "${dotfiles}/agents/skills";
      recursive = true;
    };
    "${omp}/config.yml".source = link "${dotfiles}/agents/omp/config.yml";
    "${omp}/extensions" = {
      source = link "${dotfiles}/agents/omp/extensions";
      recursive = true;
      force = true;
    };
    "${omp}/themes" = {
      source = link "${dotfiles}/agents/omp/themes";
      recursive = true;
      force = true;
    };
  };
}

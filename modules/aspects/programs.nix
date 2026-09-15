# home-manager programs that are pure option toggles (no dotfile directory of
# their own). One aspect per tool would be noise here; everything that owns a
# directory in this repo has its own aspect file.
{ den, ... }:
{
  den.aspects.programs.homeManager =
    { pkgs, ... }:
    {
      # let home-manager manage itself
      programs.home-manager.enable = true;

      # nix-direnv — single source of truth for integrations.
      # Nushell-only: fish/bash/zsh are handled via explicit shell configs,
      # not direnv's automatic hooks.
      programs.direnv = {
        enable = true;
        nix-direnv.enable = true;
        stdlib = builtins.readFile ../../direnv/direnvrc;
        enableFishIntegration = false;
        enableBashIntegration = false;
        enableNushellIntegration = true;
        enableZshIntegration = false;

        package = pkgs.direnv.overrideAttrs (old: {
          doCheck = false;
        });
      };

      programs.bat = {
        enable = true;
        config = {
          theme = "Catppuccin Latte";
          "italic-text" = "always";
          style = "numbers";
        };
      };

      programs.btop = {
        enable = true;
        settings = {
          color_theme = "paper";
        };
      };

      programs.fzf = {
        enable = true;
        # https://github.com/junegunn/fzf/blob/d579e335b5aa30e98a2ec046cb782bbb02bc28ad/README.md#respecting-gitignore
        defaultCommand = "${pkgs.fd}/bin/fd --type f --strip-cwd-prefix --hidden --follow --exclude .git";
        defaultOptions = [
          # --walker*: Default file filtering will be changed by this option if FZF_DEFAULT_COMMAND is not set: https://github.com/junegunn/fzf/pull/3649/files
          "--walker-skip '.git,node_modules,.direnv,vendor,dist'"
        ];
      };

      # completion
      programs.carapace.enable = true;
      programs.carapace.enableNushellIntegration = true;

      programs.zoxide = {
        enable = true;
        enableNushellIntegration = false; # managed manually in nushell/zoxide.nu
      };

      programs.starship = {
        enable = true;
        settings = {
          add_newline = true;
          directory.truncation_length = 8;
          git_status.format = "([\\($all_status$ahead_behind\\)]($style) )";
          git_status.ahead = "⇡$\{count\}";
          git_status.behind = "⇣$\{count\}";
          git_status.diverged = "⇕⇡$\{ahead_count\} ⇣$\{behind_count\}";
          package.disabled = true;
          golang.format = "via [ $version](bold blue) ";
          gcloud.disabled = true;
        };
      };
    };
}

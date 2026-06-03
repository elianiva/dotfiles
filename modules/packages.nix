{ pkgs, flakePkgs, ... }:

[
    # cli tools
    pkgs.tree
    pkgs.dust
    pkgs.ripgrep
    pkgs.fd
    pkgs.rclone
    pkgs.yt-dlp-light
    pkgs.yazi # tui file manager
    pkgs.pass
    pkgs.wget
    pkgs.yq
    pkgs.tree-sitter

    pkgs.caddy

    pkgs.eza # better ls
    pkgs.nh # nix helper
    pkgs.ffmpeg
    pkgs.imagemagick
    pkgs.pkg-config
    pkgs.csvlens
    pkgs.protobuf

    # finance stuff
    pkgs.beancount
    pkgs.beanquery
    pkgs.fava

    # typst related things
    pkgs.typst # documents
    pkgs.typstyle # formatting

    # editing related things
    pkgs.zellij
    pkgs.neovim
    pkgs.helix
    pkgs.ast-grep
    pkgs.fastmod

    # mobile ssh
    pkgs.mosh

    pkgs.vivid # better LS_COLORS
    pkgs.nushell
    pkgs.act

    # these are so annoying but i need them for intelephense
    pkgs.php
    pkgs.php84Packages.composer

    pkgs.bun
    pkgs.ghq
    pkgs.git-filter-repo # useful to remove accidentally committed secrets
    pkgs.delta
    pkgs.difftastic
] ++ (with flakePkgs; [
  bash-env-json
])

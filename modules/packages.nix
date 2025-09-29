{ pkgs, flakePkgs, ... }:

with pkgs; [
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
    nh # nix helper
    ffmpeg
    imagemagick

    typst # documents

    zellij
    neovim

    csvlens

    vivid
    nushell
    act

    # these are so annoying but i need them for intelephense
    php
    php84Packages.composer

    bun
    uv

    # git related
    git-filter-repo # useful to remove accidentally committed secrets
    delta
    difftastic

    # rust
    rustc
    cargo
] ++ [
  flakePkgs.bash-env-json
]

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

    typst # documents

    zellij
    neovim

    csvlens

    nushell

    # these are so annoying but i need them for intelephense
    php
    php84Packages.composer

    bun

    # git related
    git-filter-repo # useful to remove accidentally committed secrets
    delta
    difftastic

    # rust
    rustc
    cargo

    # fonts
    monaspace
    inter
    lora
] ++ [
  flakePkgs.bash-env-json
]

{ pkgs, flakePkgs, ... }:

with pkgs; [
    # cli tools
    tree
    dust
    ripgrep
    fd
    rclone
    yt-dlp
    yazi # tui file manager
    pass
    wget
    yq
    zoxide # switch between multiple projects faster
    eza # better ls
    nh # nix helper
    ffmpeg
    imagemagick
    pkg-config
    csvlens
    protobuf

    # finance stuff
    beancount
    beanquery
    fava

    # typst related things
    typst # documents
    typstyle # formatting
    zathura

    # editing related things
    zellij
    neovim
    helix
    ast-grep
    fastmod

    vivid # better LS_COLORS
    nushell
    act

    # these are so annoying but i need them for intelephense
    php
    php84Packages.composer

    bun

    # git related
    git-filter-repo # useful to remove accidentally committed secrets
    delta
    difftastic

    # rust
    (fenix.complete.withComponents [
      "cargo"
      "clippy"
      "rust-src"
      "rustc"
      "rustfmt"
    ])
    rust-analyzer
    mold
] ++ (with flakePkgs; [
  bash-env-json
]) ++ [
  # TODO: not sure if we should keep this or remove entirely
  # # language servers related things
  # harper # spell checking
  # tinymist # typst support
  # vtsls # typescript
  # superhtml # html
  # tailwindcss-language-server # tailwind
  # mdx-language-server
  # docker-language-server
  # astro-language-server
  # nil # nix lang server
  # vscode-langservers-extracted
]

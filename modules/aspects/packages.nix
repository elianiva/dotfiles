# CLI tooling. On macOS it belongs to the system profile, on Linux (non-NixOS)
# to the user's home profile — one aspect, both classes.
{
  den,
  inputs,
  lib,
  ...
}:
let
  mkCommon =
    pkgs:
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
      pkgs.pandoc
      pkgs.sshpass
      pkgs.just

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

      pkgs.zig

      # mobile ssh
      pkgs.mosh

      pkgs.vivid # better LS_COLORS
      pkgs.nushell
      pkgs.act
      pkgs.devbox

      # these are so annoying but i need them for intelephense
      pkgs.php
      pkgs.php84Packages.composer

      pkgs.ghq
      pkgs.git-filter-repo # useful to remove accidentally committed secrets
      pkgs.delta
    ]
    ++ [
      inputs.bash-env-json.packages.${pkgs.stdenv.hostPlatform.system}.default
    ];

  mkDarwin = pkgs: [
    pkgs.iina # macOS video player — no Linux equivalent needed
  ];

  mkLinux =
    pkgs:
    [
      pkgs.pinentry-gnome3
      pkgs.lazydocker
      pkgs.zathura
    ]
    # nixGL is only for x86_64 non-NixOS (Intel/Nvidia). On aarch64/Asahi the
    # host provides native Mesa (Apple AGX) and nixGL pulls i686 libs that fail
    # to evaluate on ARM.
    ++ lib.optionals (!pkgs.stdenv.hostPlatform.isAarch64) [
      inputs.nixGL.packages.${pkgs.stdenv.hostPlatform.system}.nixGLIntel
    ];
in
{
  den.aspects.packages = {
    darwin =
      { pkgs, ... }:
      {
        environment.systemPackages = mkCommon pkgs ++ mkDarwin pkgs;
      };

    homeManager =
      { pkgs, ... }:
      # `mkIf` keeps the module's top-level shape static: forcing `pkgs` during
      # module application recurses (home-manager resolves it via
      # `_module.args.pkgs`, which needs the config being built).
      lib.mkIf pkgs.stdenv.hostPlatform.isLinux {
        home.packages = mkCommon pkgs ++ mkLinux pkgs;
      };
  };
}

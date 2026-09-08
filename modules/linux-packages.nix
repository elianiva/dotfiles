{ pkgs, nixGLIntel, ... }:
# Linux-only extras. Common packages (including rust/devbox) and fonts
# are composed in linux-home.nix via packages.nix + rust.nix + fonts.nix.
[
  pkgs.pinentry-gnome3
  nixGLIntel # nixGL wrapper for non-NixOS GPU acceleration
  pkgs.lazydocker
  pkgs.zathura
]

{ pkgs, nixGLIntel ? null, lib ? pkgs.lib, inputs ? null, ... }:
# Linux-only extras. Common packages (including rust/devbox) and fonts
# are composed in linux-home.nix via packages.nix + rust.nix + fonts.nix.
# nixGLIntel is null on aarch64/Asahi where host Mesa is used directly.
([
  pkgs.pinentry-gnome3
  pkgs.lazydocker
  pkgs.zathura
]
++ lib.optionals (nixGLIntel != null) [ nixGLIntel ])

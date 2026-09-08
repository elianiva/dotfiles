{ pkgs, ... }:
# Darwin-only extras. Common packages (including rust/devbox) and fonts
# are composed in darwin-config.nix via packages.nix + rust.nix + fonts.nix.
[
  pkgs.iina # macOS video player — no Linux equivalent needed
]

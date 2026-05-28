{ pkgs, flakePkgs, ... }:

let
  shared-packages = import ./packages.nix { inherit pkgs flakePkgs; };
  rust = import ./rust.nix { inherit pkgs; };
in
shared-packages ++ [
  pkgs.nushell
  pkgs.devbox
  pkgs.jj-starship
] ++ rust

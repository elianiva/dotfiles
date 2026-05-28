{ pkgs, flakePkgs, fenix, ... }:

let
  shared-packages = import ./packages.nix { inherit pkgs flakePkgs; };
  rust = import ./rust.nix { inherit pkgs fenix; };
in
shared-packages ++ [
  pkgs.nushell
  pkgs.devbox
  pkgs.jj-starship
] ++ [ rust ]

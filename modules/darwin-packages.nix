{ pkgs, flakePkgs, fenix, ... }:

with pkgs;
let shared-packages = import ./packages.nix { inherit pkgs flakePkgs fenix; }; in
shared-packages ++ [
  nushell
  devbox
]

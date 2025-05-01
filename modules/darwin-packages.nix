{ pkgs, flakePkgs, ... }:

with pkgs;
let shared-packages = import ./packages.nix { inherit pkgs flakePkgs; }; in
shared-packages ++ [
  nushell
]

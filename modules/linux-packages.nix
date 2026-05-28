{ pkgs, flakePkgs, nixGLIntel, ... }:

let
  shared-packages = import ./packages.nix { inherit pkgs flakePkgs; };
  rust = import ./rust.nix { inherit pkgs; };
in
shared-packages ++ rust ++ [
  pkgs.pinentry-gnome3
  # nixgl is needed to access intel drivers from non-nixos environments
  nixGLIntel
  pkgs.lazydocker # manage docker stuff

  # fonts
  pkgs.monaspace
  pkgs.inter
  pkgs.lora
]

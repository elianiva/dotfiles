{ pkgs, flakePkgs, ... }:

with pkgs;
let shared-packages = import ./packages.nix { inherit pkgs flakePkgs; }; in
shared-packages ++ [
    pinentry-gnome3
    # nixgl is needed to access intel drivers from non-nixos environments
    nixGLIntel
    lazydocker # manage docker stuff

    # fonts
    monaspace
    inter
    lora
]

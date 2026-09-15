{
  description = "elianiva nix config";

  inputs = {
    nixpkgs-stable.url = "github:nixos/nixpkgs/release-24.11";
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixpkgs-unstable";
    nixpkgs.follows = "nixpkgs-unstable";

    # aspect-oriented composition over the Nix module system
    den.url = "github:denful/den";
    import-tree.url = "github:denful/import-tree";

    # nix darwin stuff
    nix-darwin.url = "github:nix-darwin/nix-darwin/master";
    nix-darwin.inputs.nixpkgs.follows = "nixpkgs";

    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";

    # manage homebrew through nix
    nix-homebrew.url = "github:zhaofengli/nix-homebrew";

    homebrew-core.url = "github:homebrew/homebrew-core";
    homebrew-core.flake = false;

    homebrew-cask.url = "github:homebrew/homebrew-cask";
    homebrew-cask.flake = false;

    homebrew-bundle.url = "github:homebrew/homebrew-bundle";
    homebrew-bundle.flake = false;

    homebrew-barutsrb.url = "github:BarutSRB/homebrew-tap";
    homebrew-barutsrb.flake = false;

    homebrew-onevcat.url = "github:onevcat/homebrew-tap";
    homebrew-onevcat.flake = false;

    # fenix for rust
    fenix.url = "github:nix-community/fenix";
    fenix.inputs.nixpkgs.follows = "nixpkgs";

    # only needed for linux
    nixGL.url = "github:nix-community/nixGL/310f8e49a149e4c9ea52f1adf70cdc768ec53f8a";
    nixGL.inputs.nixpkgs.follows = "nixpkgs";

    jj-starship.url = "github:dmmulroy/jj-starship";

    ioshelfka.url = "github:NotAShelf/Ioshelfka";

    bash-env-json = {
      url = "github:tesujimath/bash-env-json/main";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  # All of ./modules is loaded recursively by import-tree. Each file contributes
  # aspects (den.aspects.*), entities (den.hosts.*/den.homes.*), or global
  # defaults; Den resolves them into darwinConfigurations/homeConfigurations.
  outputs =
    inputs:
    (inputs.nixpkgs.lib.evalModules {
      modules = [ (inputs.import-tree ./modules) ];
      specialArgs = { inherit inputs; };
    }).config.flake;

  nixConfig = {
    trusted-substituters = [
      "https://cache.nixos.org"

      "https://nix-community.cachix.org"
    ];
    trusted-public-keys = [
      "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="

      "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
    ];
  };
}

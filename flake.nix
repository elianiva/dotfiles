{
  description = "elianiva nix config";

  inputs = {
    nixpkgs-stable.url = "github:nixos/nixpkgs/release-24.11";
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixpkgs-unstable";
    nixpkgs.follows = "nixpkgs-unstable";

    # nix darwin stuff
    nix-darwin.url = "github:nix-darwin/nix-darwin/master";
    nix-darwin.inputs.nixpkgs.follows = "nixpkgs";

    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";

    # manage homebrew through nix
    nix-homebrew.url = "github:zhaofengli/nix-homebrew";
    nix-homebrew.inputs.nixpkgs.follows = "nixpkgs";
    homebrew-core.url = "github:homebrew/homebrew-core";
    homebrew-core.flake = false;
    homebrew-cask.url = "github:homebrew/homebrew-cask";
    homebrew-cask.flake = false;
    homebrew-bundle.url = "github:homebrew/homebrew-bundle";
    homebrew-bundle.flake = false;
    homebrew-mhaeuser.url = "github:mhaeuser/homebrew-mhaeuser";
    homebrew-mhaeuser.flake = false;

    ghostty.url = "github:ghostty-org/ghostty";

    # only needed for linux
    nixGL.url = "github:nix-community/nixGL/310f8e49a149e4c9ea52f1adf70cdc768ec53f8a";
    nixGL.inputs.nixpkgs.follows = "nixpkgs";

    bash-env-json = {
      url = "github:tesujimath/bash-env-json/main";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = inputs@{
    nixpkgs,
    home-manager,
    nix-darwin,
    nix-homebrew,
    homebrew-core,
    homebrew-cask,
    homebrew-bundle,
    homebrew-mhaeuser,
    ...
  }:
    let
      lib = nixpkgs.lib;
      flakePkgs = system: {
        bash-env-json = inputs.bash-env-json.packages.${system}.default;
      };
    in
    {
      darwinConfigurations = {
        melon = nix-darwin.lib.darwinSystem {
          inherit inputs;
          system = "aarch64-darwin";
          pkgs = nixpkgs.legacyPackages."aarch64-darwin";
          specialArgs = {
            flakePkgs = flakePkgs "aarch64-darwin";
          };
          modules = [
            nix-homebrew.darwinModules.nix-homebrew
            home-manager.darwinModules.home-manager
            {
              nix-homebrew = {
                # install homebrew under default prefix
                enable = true;
                enableRosetta = true;
                user = "elianiva";
                taps = {
                  "homebrew/homebrew-core" = homebrew-core;
                  "homebrew/homebrew-cask" = homebrew-cask;
                  "homebrew/homebrew-bundle" = homebrew-bundle;
                  "mhaeuser/homebrew-mhaeuser" = homebrew-mhaeuser;
                };
                mutableTaps = false;
                autoMigrate = true;
              };
              home-manager.useGlobalPkgs = true;
              home-manager.useUserPackages = true;
              home-manager.users.elianiva = {
                imports = [
                  ./modules/darwin-home.nix
                  ./modules/git.nix
                  ./modules/gpg.nix
                ];
              };
            }
            ./modules/darwin-config.nix
          ];
        };
      };
      homeConfigurations = {
        elianiva = home-manager.lib.homeManagerConfiguration {
          system = "x86_64-linux";
          pkgs = nixpkgs.legacyPackages."x86_64-linux";
          extraSpecialArgs = {
            inherit inputs;
            flakePkgs = flakePkgs "x86_64-linux";
          };
          modules = [
            ./modules/linux-home.nix
            ./modules/gpg.nix
            ./modules/git.nix
            ./modules/terminals.nix
          ];
        };
      };
    };

  nixConfig = {
    trusted-substituters = [
      "https://cache.nixos.org"

      "https://nix-community.cachix.org"
      "https://ghostty.cachix.org"
    ];
    trusted-public-keys = [
      "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="

      "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
      "ghostty.cachix.org-1:QB389yTa6gTyneehvqG58y0WnHjQOqgnA+wBnpWWxns="
    ];
  };
}

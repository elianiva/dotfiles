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

    homebrew-core.url = "github:homebrew/homebrew-core";
    homebrew-core.flake = false;

    homebrew-cask.url = "github:homebrew/homebrew-cask";
    homebrew-cask.flake = false;

    homebrew-bundle.url = "github:homebrew/homebrew-bundle";
    homebrew-bundle.flake = false;

    homebrew-barutsrb.url = "github:BarutSRB/homebrew-tap";
    homebrew-barutsrb.flake = false;

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

  outputs =
    inputs@{
      nixpkgs,
      home-manager,
      nix-darwin,
      nix-homebrew,
      fenix,
      jj-starship,
      ...
    }:
    let
      raw-identity = import ./identity.nix;
      flakePkgs = system: {
        bash-env-json = inputs.bash-env-json.packages.${system}.default;
      };
      # Resolve platform-specific identity fields
      mkIdentity = platform: raw-identity // {
        inherit (raw-identity.platforms.${platform}) homeDir;
        dotfiles = "${raw-identity.platforms.${platform}.homeDir}/.dotfiles";
        workspacePath = "${raw-identity.platforms.${platform}.homeDir}/Development";
        repositoriesPath = "${raw-identity.platforms.${platform}.homeDir}/Repositories";
      };
      identity = mkIdentity "darwin";
    in
    {
      darwinConfigurations = {
        melon = nix-darwin.lib.darwinSystem {
          inherit inputs;
          system = "aarch64-darwin";
          # pkgs = nixpkgs.legacyPackages."aarch64-darwin";
          pkgs = import nixpkgs {
            system = "aarch64-darwin";
            overlays = [
              fenix.overlays.default
              jj-starship.overlays.default
            ];
          };
          specialArgs = {
            inherit (inputs) fenix ioshelfka;
            flakePkgs = flakePkgs "aarch64-darwin";
            inherit identity;
          };
          modules = [
            nix-homebrew.darwinModules.nix-homebrew
            home-manager.darwinModules.home-manager
            {
              nix-homebrew = {
                enable = true;
                enableRosetta = true;
                user = identity.username;
                taps = {
                  "homebrew/homebrew-core" = inputs.homebrew-core;
                  "homebrew/homebrew-cask" = inputs.homebrew-cask;
                  "homebrew/homebrew-bundle" = inputs.homebrew-bundle;
                  "BarutSRB/homebrew-tap" = inputs.homebrew-barutsrb;
                };
                mutableTaps = false;
                autoMigrate = true;
              };
              home-manager.useGlobalPkgs = true;
              home-manager.useUserPackages = true;
              home-manager.extraSpecialArgs = { inherit identity; };
              home-manager.users.${identity.username} = {
                imports = [
                  ./modules/darwin-home.nix
                  ./modules/git.nix
                  ./modules/gpg.nix
                ];
              };
            }
            # Align homebrew taps config with nix-homebrew
            ({config, lib, ...}: {
              homebrew.taps = lib.mapAttrsToList (name: _:
                let parts = lib.splitString "/" name;
                     org = lib.head parts;
                     repo = lib.last parts;
                in if org == "homebrew" then "homebrew/${lib.removePrefix "homebrew-" repo}" else name
              ) config.nix-homebrew.taps;
            })
            ./modules/darwin-config.nix
          ];
        };
      };
      homeConfigurations = {
        ${identity.username} = home-manager.lib.homeManagerConfiguration {
          system = "x86_64-linux";
          pkgs = import nixpkgs {
            system = "x86_64-linux";
            config.allowUnfree = true;
          };
          extraSpecialArgs = {
            inherit inputs;
            inherit (inputs) ioshelfka;
            identity = mkIdentity "linux";
            flakePkgs = flakePkgs "x86_64-linux";
            inherit (inputs) fenix;
          };
          modules = [
            ./modules/linux-home.nix
            ./modules/gpg.nix
            ./modules/git.nix
            ./modules/linux-terminals.nix
          ];
        };
      };
    };

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

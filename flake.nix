{
  description = "home-manager flake for non-nixos";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";
    home-manager = {
      url = "github:nix-community/home-manager";
      # url = "path:/Users/michael/Repositories/nix/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, home-manager, ... }@inputs:
    let
      username = "elianiva";
      overlays = [
        (self: super: {
          awesome-git = super.awesome.overrideAttrs (old: {
            version = "master";

            src = super.fetchFromGitHub {
              owner = "awesomewm";
              repo = "awesome";
              rev = "832483dd60ba194f3ae0200ab39a3a548c26e910";
              sha256 = "1bcbxsiydlz439af6dq69z8g7rca4jganlz65f3ajrlgqknk86cq";
            };
          });
        })
      ];
    in
    {
      homeConfigurations = {
        fedora = inputs.home-manager.lib.homeManagerConfiguration {
          system = "x86_64-linux";
          homeDirectory = "/home/${username}";
          username = username;
          configuration = { pkgs, config, ... }:
            {
              xdg.configFile."nix/nix.conf".source = ./config/nix/nix.conf;
              nixpkgs = {
                config = {
                  allowUnfree = true;
                };
                overlays = overlays;
              };
              imports = [
                ./modules/cli.nix
                ./modules/git.nix
                ./modules/neovim.nix
                ./modules/dot.nix
                ./modules/pkgs.nix
              ];
            };
        };
      };
      fedora = self.homeConfigurations.fedora.activationPackage;
    };
}

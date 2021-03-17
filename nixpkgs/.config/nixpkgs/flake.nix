{
  description = "Configurations";
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";
    nixpkgs-head.url = "nixpkgs/master";

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    neovim-nightly-overlay = {
      url = "github:nix-community/neovim-nightly-overlay";
      flake = true;
      inputs.nixpkgs.follows = "nixpkgs-head";
    };

    fast-syntax-highlighting = {
      url = "github:zdharma/fast-syntax-highlighting";
      flake = false;
    };

    zsh-history-substring-search = {
      url = "github:zsh-users/zsh-history-substring-search";
      flake = false;
    };

    zsh-autosuggestions = {
      url = "github:zsh-users/zsh-autosuggestions";
      flake = false;
    };

    nix-zsh-shell-integration = {
      url = "github:chisui/zsh-nix-shell";
      flake = false;
      inputs.nixpkgs.follows = "nixpkgs-head";
    };
  };

  outputs = { self, ... }@inputs:
    let
      overlays = [
        inputs.neovim-nightly-overlay.overlay
      ];
    in
      {
        homeConfigurations.thinkpad = inputs.home-manager.lib.homeManagerConfiguration {
          configuration = { pkgs, ... }: {
            nixpkgs.overlays = overlays;
            imports = [
              ./modules/home-manager.nix
              ./modules/git.nix
              ./modules/browser.nix
              ./modules/neovim.nix
              ./modules/chat.nix
              ./modules/wayland.nix
            ];
          };
          system = "x86_64-linux";
          homeDirectory = "/home/elianiva";
          username = "elianiva";
        };
        thinkpad = self.homeConfigurations.thinkpad.activationPackage;
      };
}

{ pkgs, flakePkgs, config, ... }:

let
  user = "elianiva";
in
{
    system.stateVersion = 6;

    users.users.${user} = {
      name = "${user}";
      home = "/Users/${user}";
    };

    # allow unfree packages
    nixpkgs = {
      config = {
        allowUnfree = true;
        allowUnfreePredicate = (_: true);
      };
    };

    # setup nix
    nix.enable = false;

    homebrew = {
      enable = true;
      casks = pkgs.callPackage ./casks.nix { };
      caskArgs = {
        appdir = "~/Applications";
        require_sha = true;
      };
      onActivation = {
        cleanup = "zap";
        extraFlags = [ "--verbose" ];
      };
      global = {
        brewfile = true;
      };
    };

    environment.systemPackages = import ./darwin-packages.nix { inherit pkgs flakePkgs; };

    # enable touchid for sudo
    security.pam.services.sudo_local.touchIdAuth = true;

    system.defaults.dock = {
      autohide = true;
      mineffect = "scale";
    };
}

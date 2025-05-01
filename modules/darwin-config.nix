{ pkgs, flakePkgs, config, ... }:

let
  user = "elianiva";
  hostname = "melon";
in
{
    system.stateVersion = 6;

    networking.hostName = "${hostname}";
    networking.localHostName = "${hostname}";

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

    # keyboard
    system.keyboard.enableKeyMapping = true;
    system.keyboard.remapCapsLockToEscape = true;

     # docks
    system.defaults.dock = {
      autohide = true;
      mineffect = "scale";
      magnification = true;
      show-recents = false;
      persistent-apps = [
        "/Users/${user}/Applications/Visual Studio Code.app"
        "/Users/${user}/Applications/Ghostty.app"
        "/Applications/Zen.app"
      ];
    };

    # misc settings
    system.defaults.NSGlobalDomain = {
      InitialKeyRepeat = 10;
      KeyRepeat = 10;

      NSAutomaticCapitalizationEnabled = false;
      NSAutomaticSpellingCorrectionEnabled = false;
    };

    system.defaults.finder = {
      AppleShowAllExtensions = true;
      CreateDesktop = false;
      FXDefaultSearchScope = "SCcf";
      FXPreferredViewStyle = "clmv";
      ShowPathbar = true;
    };

    system.defaults.screencapture = {
      disable-shadow = true;
      location = "~/Pictures/Screenshots";
    };

    system.defaults.trackpad = {
      Clicking = true;
      TrackpadThreeFingerDrag = true;
    };

    system.defaults.hitoolbox.AppleFnUsageType = "Change Input Source";
}

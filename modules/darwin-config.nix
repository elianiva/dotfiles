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
      brews = pkgs.callPackage ./brews.nix { };
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
    fonts.packages = with pkgs; [ monaspace inter lora ];

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
      appswitcher-all-displays = true;
    };

    # misc settings
    system.defaults.NSGlobalDomain = {
      # Repeat character while key held instead of showing character accents menu
      ApplePressAndHoldEnabled = false;

      # fastest possible key repeat with minimum delay
      InitialKeyRepeat = 15;
      KeyRepeat = 2;

      # turn off font smoothing
      AppleFontSmoothing = 0;

      NSAutomaticCapitalizationEnabled = false;
      NSAutomaticSpellingCorrectionEnabled = false;

      # faster trackpad speed
      "com.apple.trackpad.scaling" = 2.0;

      # enable forceclick to show definition
      "com.apple.trackpad.forceClick" = true;
    };

    system.defaults.finder = {
      AppleShowAllExtensions = true;
      CreateDesktop = false;
      FXDefaultSearchScope = "SCcf";
      FXPreferredViewStyle = "clmv";
      FXRemoveOldTrashItems = true;
      _FXSortFoldersFirst = true;
      ShowPathbar = true;
    };

    system.defaults.screencapture = {
      disable-shadow = false;
      location = "~/Pictures/Screenshots";
    };

    system.defaults.trackpad = {
      Clicking = true;
      TrackpadThreeFingerDrag = true;
    };

    system.defaults.hitoolbox.AppleFnUsageType = "Change Input Source";

    # ads
    system.defaults.CustomUserPreferences."com.apple.AdLib" = {
      allowApplePersonalizedAdvertising = false;
      allowIdentifierForAdvertising = false;
    };

    # disable power chime sound
    system.defaults.CustomUserPreferences."com.apple.PowerChime".ChimeOnNoHardware = false;
}

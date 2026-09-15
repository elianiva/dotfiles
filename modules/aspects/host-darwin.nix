# The macOS host: everything system-level that only applies to `melon`.
{
  den,
  inputs,
  lib,
  ...
}:
let
  inherit (import ../_lib/identity.nix { inherit lib; }) homeDirFor;
in
{
  den.aspects.melon = {
    includes = [ den.aspects.homebrew ];

    darwin =
      { host, ... }:
      let
        homeDir = homeDirFor host.system;
      in
      {
        # nixpkgs instance for this host: unfree + the overlays that provide
        # pkgs.fenix (see ./rust.nix) and pkgs.jj-starship.
        nixpkgs = {
          config.allowUnfree = true;
          overlays = [
            inputs.fenix.overlays.default
            inputs.jj-starship.overlays.default
          ];
        };

        # nix is managed by the official installer, not nix-darwin
        nix.enable = false;

        networking.localHostName = host.hostName;

        # the user's home-manager profile runs inside this host, sharing its pkgs
        home-manager.useGlobalPkgs = true;
        home-manager.useUserPackages = true;

        # enable touchid for sudo
        security.pam.services.sudo_local.touchIdAuth = true;

        # keyboard (handled by karabiner-elements for multi-keyboard support)
        system.keyboard.enableKeyMapping = false;

        # docks
        system.defaults.dock = {
          autohide = true;
          mineffect = "scale";
          magnification = true;
          show-recents = false;
          persistent-apps = [
            "${homeDir}/Applications/Ghostty.app"
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
      };
  };
}

# Declarative homebrew: nix-homebrew owns the taps, homebrew owns the CLI.
{
  den,
  inputs,
  lib,
  ...
}:
let
  inherit (import ../_lib/identity.nix { inherit lib; }) username;
in
{
  den.aspects.homebrew.darwin =
    { config, ... }:
    {
      imports = [ inputs.nix-homebrew.darwinModules.nix-homebrew ];

      nix-homebrew = {
        enable = true;
        enableRosetta = true;
        user = username;
        taps = {
          "homebrew/homebrew-core" = inputs.homebrew-core;
          "homebrew/homebrew-cask" = inputs.homebrew-cask;
          "homebrew/homebrew-bundle" = inputs.homebrew-bundle;
          "BarutSRB/homebrew-tap" = inputs.homebrew-barutsrb;
          "onevcat/homebrew-tap" = inputs.homebrew-onevcat;
        };
        mutableTaps = false;
        autoMigrate = true;
      };

      homebrew = {
        enable = true;
        brews = import ../_lib/brews.nix;
        casks = import ../_lib/casks.nix;
        caskArgs = {
          appdir = "~/Applications";
          require_sha = true;
        };
        onActivation = {
          autoUpdate = true;
          upgrade = true;
          cleanup = "zap";
          extraFlags = [ "--verbose" ];
        };
        global = {
          brewfile = true;
        };
      };

      # Align homebrew taps config with nix-homebrew
      homebrew.taps = lib.mapAttrsToList (
        name: _:
        let
          parts = lib.splitString "/" name;
          org = lib.head parts;
          repo = lib.last parts;
        in
        if org == "homebrew" then "homebrew/${lib.removePrefix "homebrew-" repo}" else name
      ) config.nix-homebrew.taps;
    };
}

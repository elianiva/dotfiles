# Topology: which machines and which homes exist, and which aspect configures
# each one. Nothing else lives here — the aspects themselves are in ./aspects.
{ den, inputs, ... }:
let
  # Standalone home-manager owns its own nixpkgs instance, so the overlays that
  # nix-darwin gets from `nixpkgs.overlays` (see ./aspects/host-darwin.nix) have
  # to be applied here too.
  mkPkgs =
    system:
    import inputs.nixpkgs {
      inherit system;
      config.allowUnfree = true;
      overlays = [
        inputs.fenix.overlays.default
        inputs.jj-starship.overlays.default
      ];
    };
in
{
  # macOS: the user's home-manager profile is nested inside this host.
  den.hosts.aarch64-darwin.melon.users.elianiva = { };

  # Linux boxes are not NixOS, so they only get a standalone home-manager.
  # `elianiva@intel` / `elianiva@asahi` bind the home to a hostname, which lets
  # the `home-manager` CLI pick the right output on those machines.
  den.homes = {
    aarch64-linux.elianiva = {
      aspect = den.aspects.elianiva-linux;
      pkgs = mkPkgs "aarch64-linux";
    };

    x86_64-linux."elianiva@intel" = {
      aspect = den.aspects.elianiva-linux;
      pkgs = mkPkgs "x86_64-linux";
    };

    aarch64-linux."elianiva@asahi" = {
      aspect = den.aspects.elianiva-linux;
      pkgs = mkPkgs "aarch64-linux";
    };
  };
}

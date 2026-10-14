# Bazel build tool. On macOS it belongs to the system profile, on Linux
# (non-NixOS) to the user's home profile — one aspect, both classes.
{
  den,
  lib,
  ...
}:
let
  mkBazel = pkgs: [
    pkgs.bazel
  ];
in
{
  den.aspects.bazel = {
    darwin =
      { pkgs, ... }:
      {
        environment.systemPackages = mkBazel pkgs;
      };

    homeManager =
      { pkgs, ... }:
      # `mkIf` keeps the module's top-level shape static: forcing `pkgs` during
      # module application recurses (home-manager resolves it via
      # `_module.args.pkgs`, which needs the config being built).
      lib.mkIf pkgs.stdenv.hostPlatform.isLinux {
        home.packages = mkBazel pkgs;
      };
  };
}

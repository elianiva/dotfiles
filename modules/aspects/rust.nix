# Rust toolchain. `pkgs.fenix` comes from the fenix overlay, which is applied
# to the darwin host pkgs and to each standalone home pkgs (see ./hosts.nix).
{ den, lib, ... }:
let
  mkRust = pkgs: [
    (pkgs.fenix.complete.withComponents [
      "cargo"
      "clippy"
      "rust-src"
      "rustc"
      "rustfmt"
    ])
    pkgs.rust-analyzer
  ];
in
{
  den.aspects.rust = {
    darwin =
      { pkgs, ... }:
      {
        environment.systemPackages = mkRust pkgs;
      };

    homeManager =
      { pkgs, ... }:
      # `mkIf` keeps the module's top-level shape static: forcing `pkgs` during
      # module application recurses (home-manager resolves it via
      # `_module.args.pkgs`, which needs the config being built).
      lib.mkIf pkgs.stdenv.hostPlatform.isLinux {
        home.packages = mkRust pkgs;
      };
  };
}

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
      lib.optionalAttrs pkgs.stdenv.hostPlatform.isLinux {
        home.packages = mkRust pkgs;
      };
  };
}

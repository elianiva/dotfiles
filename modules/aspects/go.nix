# Go toolchain + everyday dev tools. On macOS it belongs to the system
# profile, on Linux (non-NixOS) to the user's home profile — one aspect,
# both classes.
#
# GOPATH/GOBIN/PATH live in misc/.profile (sourced by fish via
# conf.d/foreign.fish and by nushell via bash-env), so every shell already
# sees ~/.local/go/bin — this aspect only owns the nix-provided binaries.
{
  den,
  lib,
  ...
}:
let
  mkGo = pkgs: [
    pkgs.go # toolchain (go, gofmt)
    pkgs.delve # debugger (dlv)
    pkgs.golangci-lint # meta-linter
    pkgs.gofumpt # stricter gofmt
    pkgs.gotools # godoc, goimports, etc.
  ];
in
{
  den.aspects.go = {
    darwin =
      { pkgs, ... }:
      {
        environment.systemPackages = mkGo pkgs;
      };

    homeManager =
      { pkgs, ... }:
      # `mkIf` keeps the module's top-level shape static: forcing `pkgs` during
      # module application recurses (home-manager resolves it via
      # `_module.args.pkgs`, which needs the config being built).
      lib.mkIf pkgs.stdenv.hostPlatform.isLinux {
        home.packages = mkGo pkgs;
      };
  };
}

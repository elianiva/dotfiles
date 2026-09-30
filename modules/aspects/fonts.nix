# Fonts are a system concern on macOS and a home concern on Linux.
{
  den,
  inputs,
  lib,
  ...
}:
let
  mkFonts =
    pkgs:
    import ../_lib/fonts.nix {
      inherit pkgs;
      ioshelfka = inputs.ioshelfka;
    };
in
{
  den.aspects.fonts = {
    darwin =
      { pkgs, ... }:
      {
        fonts.packages = mkFonts pkgs;
      };

    homeManager =
      { pkgs, ... }:
      # `mkIf` keeps the module's top-level shape static: forcing `pkgs` during
      # module application recurses (home-manager resolves it via
      # `_module.args.pkgs`, which needs the config being built).
      lib.mkIf pkgs.stdenv.hostPlatform.isLinux {
        home.packages = mkFonts pkgs;

        fonts.fontconfig = {
          enable = true;
          defaultFonts = {
            monospace = [ "JetBrainsMono" ];
            sansSerif = [ "Inter" ];
          };
        };
      };
  };
}

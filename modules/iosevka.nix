# Official Iosevka release (v34.8.0) — the plain "regular" Iosevka family.
# The "-sgr-" infix in the package name means the zip contains a single group
# (one variant + spacing): just Iosevka, no Term/Fixed variants, default spacing.
# One .ttc per weight, fetched directly from the official releases since
# nixpkgs doesn't ship this exact package.
# https://github.com/be5invis/Iosevka/releases/tag/v34.8.0
{ pkgs, lib, ... }:
let
  iosevka = pkgs.stdenv.mkDerivation {
    pname = "iosevka";
    version = "34.8.0";

    src = pkgs.fetchzip {
      url = "https://github.com/be5invis/Iosevka/releases/download/v34.8.0/PkgTTC-SGr-Iosevka-34.8.0.zip";
      hash = "sha256-9kBC9n3MQ4RJJe2nJ8WbsWFQVyzEoJiUA47gLNjyj7A=";
      # .ttc files sit at the zip root
      stripRoot = false;
    };

    installPhase = ''
      runHook preInstall
      install -Dm644 -t "$out/share/fonts/truetype/iosevka" ./*.ttc
      runHook postInstall
    '';

    meta = {
      description = "Iosevka 34.8.0, default spacing, TTC package from official releases";
      homepage = "https://github.com/be5invis/Iosevka";
      license = lib.licenses.ofl;
      platforms = lib.platforms.all;
    };
  };
in
{
  fonts.packages = [ iosevka ];
}

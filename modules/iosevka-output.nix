# Custom Iosevka build ("Iosevka Output") by ashton314, modeled after Input Mono.
# Not packaged in nixpkgs, so we fetch the release zip and install the TTFs ourselves.
# https://codeberg.org/ashton314/iosevka-output
{ pkgs, lib, ... }:
let
  iosevka-output = pkgs.stdenv.mkDerivation {
    pname = "iosevka-output";
    version = "0.4.1";

    src = pkgs.fetchzip {
      url = "https://codeberg.org/ashton314/iosevka-output/releases/download/0.4.1-release/iosevka-output-0.4.1.zip";
      hash = "sha256-VlsHzQBMF5ztnmKsQTMvJE5WgMuh7dlUJjC+ladbPSM=";
      # zip contains iosevka-output-0.4.1/ (plus __MACOSX junk), so keep the root dir
      stripRoot = false;
    };

    installPhase = ''
      runHook preInstall
      install -Dm644 -t "$out/share/fonts/truetype/iosevka-output" iosevka-output-0.4.1/ttf-unhinted/*.ttf
      runHook postInstall
    '';

    meta = {
      description = "Custom Iosevka build modeled after Input Mono";
      homepage = "https://codeberg.org/ashton314/iosevka-output";
      # The repo's LICENSE covers only the build config; the fonts are Iosevka's (SIL OFL 1.1)
      license = lib.licenses.ofl;
      platforms = lib.platforms.all;
    };
  };
in
{
  fonts.packages = [ iosevka-output ];
}

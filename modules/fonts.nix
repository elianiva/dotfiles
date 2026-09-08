# Single source of truth for font packages.
# Used by darwin-config.nix (fonts.packages) and linux-home.nix (home.packages + fontconfig).
{ pkgs, ioshelfka, lib ? pkgs.lib }:
let
  # Official Iosevka release (v34.8.0) — plain "regular" Iosevka family.
  # The "-sgr-" infix means single group, default spacing. One .ttc per weight.
  # https://github.com/be5invis/Iosevka/releases/tag/v34.8.0
  iosevka = pkgs.stdenv.mkDerivation {
    pname = "iosevka";
    version = "34.8.0";
    src = pkgs.fetchzip {
      url = "https://github.com/be5invis/Iosevka/releases/download/v34.8.0/PkgTTC-SGr-Iosevka-34.8.0.zip";
      hash = "sha256-9kBC9n3MQ4RJJe2nJ8WbsWFQVyzEoJiUA47gLNjyj7A=";
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
  ioshelfkaMono =
    if ioshelfka.packages ? ${pkgs.hostPlatform.system} then
      [ ioshelfka.packages.${pkgs.hostPlatform.system}.ioshelfka-mono-nerd ]
    else
      [ ]; # not available for this platform (e.g. aarch64-darwin)
  baseFonts = [
    pkgs.monaspace
    pkgs.inter
    pkgs.lora
    pkgs.lilex
    pkgs.departure-mono
  ];
in
baseFonts ++ ioshelfkaMono ++ [ iosevka ]

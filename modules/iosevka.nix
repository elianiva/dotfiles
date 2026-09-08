# Deprecated: use modules/fonts.nix instead. Kept for backwards compatibility.
# The Iosevka derivation is now defined once in fonts.nix.
{ pkgs, ioshelfka ? null, lib ? pkgs.lib, ... }:
let
  fonts = if ioshelfka != null then import ./fonts.nix { inherit pkgs ioshelfka; } else [];
  # fonts.nix returns all fonts; last element is the custom Iosevka TTC.
  iosevka = if fonts != [] then builtins.elemAt fonts (builtins.length fonts - 1) else null;
in
{
  fonts.packages = lib.optionals (iosevka != null) [ iosevka ];
}

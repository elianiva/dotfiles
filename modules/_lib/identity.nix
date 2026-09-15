# Static identity data + the platform → home directory mapping.
#
# Aspects derive everything else from the context they run in
# (host.system, pkgs.stdenv.hostPlatform, config.home.homeDirectory), so this is
# plain data rather than a Nix module.
{ lib }:
let
  username = "elianiva";

  gitIdentity = {
    name = "elianiva";
    email = "git@elianiva.com";
  };
in
{
  inherit username gitIdentity;

  # Mirrors den.batteries.define-user: /Users/<user> on macOS, /home/<user> elsewhere.
  homeDirFor =
    system: if lib.hasSuffix "-darwin" system then "/Users/${username}" else "/home/${username}";
}

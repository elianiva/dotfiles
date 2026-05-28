# Shared helpers for home-manager modules
# Usage: let helpers = import ./helpers.nix { inherit config; }; in ...
{ config }:
{
  link = config.lib.file.mkOutOfStoreSymlink;
}

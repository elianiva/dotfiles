# Bootstrap `vp` and install missing global packages on activation.
{ den, ... }:
let
  vpPkgs = import ../_lib/vp-global-packages.nix;
in
{
  den.aspects.vp-global-packages.homeManager =
    { lib, ... }:
    {
      home.activation.vp-global-packages = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
        vp="$HOME/.vite-plus/bin/vp"
        if [[ ! -f "$vp" ]]; then
          $DRY_RUN_CMD curl -fsSL https://vite.plus | bash
        fi
        if [[ -f "$vp" ]]; then
          installed=$("$vp" list -g --json 2>/dev/null | sed -n 's/.*"name": "\([^"]*\)".*/\1/p')
          missing=""
          for pkg in ${builtins.toString vpPkgs.globalPackages}; do
            if ! echo "$installed" | grep -qxF "$pkg"; then
              missing="$missing $pkg"
            fi
          done
          if [[ -n "$missing" ]]; then
            $DRY_RUN_CMD "$vp" install -g $missing
          fi
        fi
      '';
    };
}

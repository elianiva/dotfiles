# Linux-only home-manager plumbing: the boxes are not NixOS, so the user
# profile has to bring its own nix + GL story. Included only by
# den.aspects.elianiva-linux, so nothing here needs a platform check.
{ den, inputs, ... }:
{
  den.aspects.home-linux.homeManager =
    { pkgs, lib, ... }:
    {
      targets.genericLinux.enable = true;

      # nixGL is only needed on x86_64 non-NixOS. On aarch64/Asahi, Fedora
      # provides native Mesa (Apple AGX) via the host — wrapping mismatches
      # host Mesa and pulls i686 libs that fail to eval on ARM.
      targets.genericLinux.nixGL = lib.mkIf (!pkgs.stdenv.hostPlatform.isAarch64) {
        packages = inputs.nixGL.packages;
        defaultWrapper = "mesa";
        installScripts = [ "mesa" ];
      };

      # nix is managed by home-manager on Linux (unlike macOS where nix-darwin
      # handles it)
      nix = {
        enable = true;
        package = pkgs.nixVersions.stable;

        gc = {
          automatic = true;
          frequency = "weekly";
          options = "--delete-older-than 7d";
        };
        settings.auto-optimise-store = true;
      };
    };
}

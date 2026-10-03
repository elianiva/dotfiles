# karabiner-elements config — macOS only.
{ den, ... }:
{
  den.aspects.karabiner.homeManager =
    {
      config,
      pkgs,
      lib,
      ...
    }:
    let
      link = config.lib.file.mkOutOfStoreSymlink;
    in
    # `mkIf` keeps the module's top-level shape static: forcing `pkgs` during
    # module application recurses (home-manager resolves it via
    # `_module.args.pkgs`, which needs the config being built).
    lib.mkIf pkgs.stdenv.hostPlatform.isDarwin {
      # `force` because Karabiner.app rewrites karabiner.json in place (and
      # recreates it if missing), which would otherwise fail activation with
      # "would be clobbered". The dotfiles copy is canonical.
      xdg.configFile."karabiner/karabiner.json" = {
        source = link "${config.home.homeDirectory}/.dotfiles/karabiner/karabiner.json";
        force = true;
      };
    };
}

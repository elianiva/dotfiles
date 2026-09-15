{ den, ... }:
{
  den.aspects.qmd.homeManager =
    { config, ... }:
    let
      link = config.lib.file.mkOutOfStoreSymlink;
    in
    {
      xdg.configFile."qmd/index.yml".source = link "${config.home.homeDirectory}/.dotfiles/qmd/index.yml";
    };
}

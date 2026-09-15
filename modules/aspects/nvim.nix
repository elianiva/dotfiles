{ den, ... }:
{
  den.aspects.nvim.homeManager =
    { config, ... }:
    let
      link = config.lib.file.mkOutOfStoreSymlink;
    in
    {
      xdg.configFile."nvim" = {
        source = link "${config.home.homeDirectory}/.dotfiles/nvim";
        recursive = true;
      };
    };
}

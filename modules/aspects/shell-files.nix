# POSIX shell startup files that are not managed by a `programs.*` module.
{ den, ... }:
{
  den.aspects.shell-files.homeManager =
    { config, ... }:
    let
      link = config.lib.file.mkOutOfStoreSymlink;
      dotfiles = "${config.home.homeDirectory}/.dotfiles";
    in
    {
      home.file = {
        ".profile".source = link "${dotfiles}/misc/.profile";
        ".bashrc".source = link "${dotfiles}/misc/.bashrc";
      };
    };
}

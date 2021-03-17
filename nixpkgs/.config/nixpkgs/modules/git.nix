{ config, pkgs, libs, ... }:
{
  home.packages = with pkgs; [
    git
    gitAndTools.delta
    gitAndTools.gh
    subversion
  ];
  home.file.".config/git/ignore".text = ''
    tags
    result
  '';
}

{ config, pkgs, libs, home-manager, ... }:
{
  home.packages = with pkgs; [
    # won't be needing these in fedora
    # noto-fonts            # a bunch of useful fonts
    # noto-fonts-cjk        # CJK characters support
    # noto-fonts-emoji      # emojis

    inter                 # default UI font
    mplus-outline-fonts   # preferred japanese font

    # only pick JetBrainsMono instead of the entire Nerdfont
    (nerdfonts.override { fonts = [ "JetBrainsMono" ]; })
  ];
}

{ pkgs, config, home-manager, ... }:
let
  link = path:
    config.lib.file.mkOutOfStoreSymlink
      "${config.home.homeDirectory}/Repos/dotfiles/${path}";
in
{
  home.file = {
    ".config/TrollTech.conf".source     = link "config/kdeplasma/TrollTech.conf";
    ".config/baloofilerc".source        = link "config/kdeplasma/baloofilerc";
    ".config/gtkrc".source              = link "config/kdeplasma/gtkrc";
    ".config/gtkrc-2.0".source          = link "config/kdeplasma/gtkrc-2.0";
    ".config/kcminputrc".source         = link "config/kdeplasma/kcminputrc";
    ".config/kded5rc".source            = link "config/kdeplasma/kded5rc";
    ".config/kdeglobals".source         = link "config/kdeplasma/kdeglobals";
    ".config/kfontinstuirc".source      = link "config/kdeplasma/kfontinstuirc";
    ".config/kglobalshortcutsrc".source = link "config/kdeplasma/kglobalshortcutsrc";
    ".config/khotkeysrc".source         = link "config/kdeplasma/khotkeysrc";
    ".config/krunnerrc".source          = link "config/kdeplasma/krunnerrc";
    ".config/kscreenlockerrc".source    = link "config/kdeplasma/kscreenlockerrc";
    ".config/ksmserverrc".source        = link "config/kdeplasma/ksmserverrc";
    ".config/kwalletrc".source          = link "config/kdeplasma/kwalletrc";
    ".config/kwinrc".source             = link "config/kdeplasma/kwinrc";
    ".config/kwinrulesrc".source        = link "config/kdeplasma/kwinrulesrc";
    ".config/plasmarc".source           = link "config/kdeplasma/plasmarc";
    ".config/plasmanotifyrc".source           = link "config/kdeplasma/plasmanotifyrc";
    ".config/ktimezonedrc".source           = link "config/kdeplasma/ktimezonedrc";
    ".config/plasma-localerc".source           = link "config/kdeplasma/plasma-localerc";
  };
}

{ pkgs, config, home-manager, ... }:
let
  link = path:
    config.lib.file.mkOutOfStoreSymlink
      "${config.home.homeDirectory}/Repos/dotfiles/${path}";
in
{
  home.file = {
    ".config/alacritty".source     = link "config/alacritty";
    ".config/kitty".source         = link "config/kitty";
    ".config/awesome".source       = link "config/awesome";
    ".config/fontconfig".source    = link "config/fontconfig";
    ".config/nvim".source          = link "config/nvim";
    ".config/lf".source            = link "config/lf";
    ".config/picom.conf".source    = link "config/misc/picom.conf";
    ".config/aliasrc".source       = link "config/misc/aliasrc";
    ".config/rofi".source          = link "config/rofi";
    ".config/starship.toml".source = link "config/misc/starship.toml";
    ".config/zathurarc".source     = link "config/misc/zathurarc";
    ".config/qt5ct".source         = link "config/qt5ct";
    ".tmux.conf".source            = link "config/tmux/.tmux.conf";
    ".scripts".source              = link "config/scripts";
    ".profile".source              = link "config/misc/.profile";
    ".xinitrc".source              = link "config/misc/.xinitrc";
    ".xprofile".source             = link "config/misc/.xprofile";
    ".Xresources".source           = link "config/misc/.Xresources";
    ".zprofile".source             = link "config/zsh/.zprofile";
    ".zshenv".source               = link "config/zsh/.zshenv";
    ".zshrc".source                = link "config/zsh/.zshrc";
    ".gitconfig".source            = link "config/git/config";
    ".gnupg/gpg-agent.conf".text   = "pinentry-program ${pkgs.pinentry.gnome3}/bin/pinentry";

    # These stuff are not used ATM
    # ".config/pacman".source  = link ../config/pacman;
    # ".config/sway".source    = link ../sway;
    # ".config/wofi".source    = link ../wofi;
    # ".config/waybar".source  = link ../waybar;
    # ".config/sxhkd".source   = link ../sxhkd;
    # ".config/mako".source    = link ../mako;
    # ".config/bspwm".source   = link ../bspwm;
    # ".config/i3".source      = link ../i3;
    # ".config/polybar".source = link ../polybar;
    # ".config/openbox".source = link ../openbox;
    # ".config/qt5ct".source   = link ../qt5ct;
  };
}

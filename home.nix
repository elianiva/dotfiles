{ config, pkgs, ... }:

let
  user = "elianiva";
  numixIcon = pkgs.numix-icon-theme.out;
  basicPackages = with pkgs; [
    nixUnstable          # unstable version of nix
    ripgrep              # super fast grep
    mycli                # mysql client
    picom                # compositor
    simplescreenrecorder # screen recorder
    flameshot            # screenshot utility
    lf                   # TUi based file explorer
    xclip                # clipboard
    numixIcon            # numix icon theme
    skim                 # fzf in rust
    rofi                 # popup launcher menu
    exa                  # better `ls` replacement
    nodejs-16_x          # js runtime; without npm
    awesome-git          # awesomewm git version
    tdesktop             # telegram desktop client
    numix-cursor-theme   # cursor based on numix
  ];
  customFonts = with pkgs; [
    noto-fonts            # a bunch of useful fonts
    noto-fonts-cjk        # CJK characters support
    noto-fonts-emoji      # emojis
    inter                 # default UI font
    mplus-outline-fonts   # preferred japanese font

    # only pick JetBrainsMono instead of the entire Nerdfont
    (nerdfonts.override { fonts = [ "JetBrainsMono" ]; })
  ];
  link = config.lib.file.mkOutOfStoreSymlink;
in {
  # let home-manager manage itself
  programs.home-manager.enable = true;

  home = {
    username = user;
    homeDirectory = "/home/${user}";
    stateVersion = "21.05";
  };

  nixpkgs = {
    config = {
      allowUnfree = true;
    };
    overlays = [
      (self: super: {
        awesome-git = super.awesome.overrideAttrs (old: {
          version = "master";

          src = super.fetchFromGitHub {
            owner = "awesomewm";
            repo = "awesome";
            rev = "a4572b9b52d89369ce3bd462904d536ec116dc35";
            sha256 = "1kj2qz2ns0jn5gha4ryr8w8vvy23s3bb5z3vjhwwfnrv7ypb40iz";
          };
        });
      })
    ];
  };

  home.packages = basicPackages ++ customFonts;

  home.sessionVariables = {
    # this is necessary for svg gtk icons
    GDK_PIXBUF_MODULE_FILE = "$(ls ${pkgs.librsvg.out}/lib/gdk-pixbuf-*/*/loaders.cache)";
    NIX_CONF_DIR = "/home/${user}/.config/nixpkgs";
  };

  # make fonts installed through nix discoverable
  fonts.fontconfig.enable = true;

  gtk = {
    enable = true;
    font = {
      name = "Inter";
      size = 11;
    };
    # TODO(elianiva): nixify my gruvbox theme
    theme.name = "gruvbox";
    iconTheme = {
      name = "Numix";
      package = pkgs.numix-icon-theme;
    };
    gtk3.extraConfig = {
      gtk-cursor-theme-name = "Numix-Cursor";
    };
  };

  qt = {
    enable = true;
    platformTheme = "gtk";
    style.name = "gtk2";
  };

  xdg = {
    enable = true;
    userDirs = {
      enable = true;
      documents = "$HOME/dox";
      download = "$HOME/dls";
      pictures = "$HOME/pix";
      desktop = "$HOME/desktop";
      publicShare = "$HOME/share";
      templates = "$HOME/templates";
      videos = "$HOME/vids";
      music = "/dev/null";
    };
    systemDirs.data = [
      "/home/${user}/.nix-profile/share"
      "/usr/loca/share"
      "/usr/share"
      "/home/${user}/.local/share"
    ];
  };

  programs.git = {
    enable = true;
    userName = "elianiva";
    userEmail = "dicha.arkana03@gmail.com";
    signing = {
      gpgPath = "/usr/bin/gpg"; # use Arch's builtin gpg
      signByDefault = true;
      key = "7076C2B10CBAB9CF3CBA70FF6035FB45062CDE53"; # not sure about this one
    };
    aliases = {
      lg = "log --graph --pretty=format:'%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr)%Creset' --abbrev-commit --date=relative";
    };
    delta = {
      enable = true;
      options = {
        line-numbers = true;
        syntax-theme = "base16";
        side-by-side = false;
        file-modified-label = "modified";
      };
    };
    extraConfig = {
      init = { defaultBranch = "master"; };
      core = { editor = "nvim"; };
      pull = { rebase = true; };
      credential = { helper = "cache --timeout 86400"; };
    };
  };

  programs.gh = {
    enable = true;
    gitProtocol = "ssh";
  };

  programs.htop = {
    enable = true;
    enableMouse = true;
    highlightBaseName = true;
    highlightThreads = true;
    showCpuFrequency = true;
  };

  programs.bat = {
    enable = true;
    config = {
      theme = "base16";
      style = "plain";
    };
  };

  home.file = {
    ".config/nixpkgs/nix.conf".source = link ./nixpkgs/nix.conf;
    ".config/alacritty".source        = link ./alacritty;
    ".config/awesome".source          = link ./awesome;
    ".config/nvim".source             = link ./nvim;
    ".config/lf".source               = link ./lf;
    ".config/picom.conf".source       = link ./misc/picom.conf;
    ".config/aliasrc".source          = link ./misc/aliasrc;
    ".config/pacman".source           = link ./pacman;
    ".config/rofi".source             = link ./rofi;
    ".config/starship.toml".source    = link ./misc/starship.toml;
    ".config/zathurarc".source        = link ./misc/zathurarc;
    ".tmux.conf".source               = link ./tmux/.tmux.conf;
    ".scripts".source                 = link ./scripts;
    ".profile".source                 = link ./misc/.profile;
    ".pam_environment".source         = link ./misc/.pam_environment;
    ".xinitrc".source                 = link ./misc/.xinitrc;
    ".xprofile".source                = link ./misc/.xprofile;
    ".Xresources".source              = link ./misc/.Xresources;
    ".zprofile".source                = link ./zsh/.zprofile;
    ".zshenv".source                  = link ./zsh/.zshenv;
    ".zshrc".source                   = link ./zsh/.zshrc;

    # These stuff are not used ATM
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

  services.clipmenu.enable = true;
}

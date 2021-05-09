{ config, pkgs, ... }:

let
  user = "elianiva";
  numixIcon = pkgs.numix-icon-theme.out;
  languageServers = with pkgs.nodePackages; [
    prettier
    typescript # this is needed for tsserver

    # language servers
    typescript-language-server
    svelte-language-server
    vscode-json-languageserver-bin
    vscode-html-languageserver-bin
    vscode-css-languageserver-bin
  ];
  customFonts = with pkgs; [
    noto-fonts
    noto-fonts-cjk
    noto-fonts-emoji
    inter
    mplus-outline-fonts # preferred japanese font
    (nerdfonts.override { fonts = [ "JetBrainsMono" ]; })
  ];
  link = config.lib.file.mkOutOfStoreSymlink;
in {
  programs.home-manager.enable = true;

  home = {
    username = user;
    homeDirectory = "/home/${user}";
    stateVersion = "21.05";
  };

  nixpkgs.overlays = [
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

  home.packages = with pkgs; [
    nixUnstable          # needed for flakes
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
    nodejs               # js runtime
    awesome-git          # awesomewm git version
  ] ++ languageServers
    ++ customFonts;

  home.sessionVariables = {
    GDK_PIXBUF_MODULE_FILE = "$(ls ${pkgs.librsvg.out}/lib/gdk-pixbuf-*/*/loaders.cache)";
    XDG_DATA_DIRS = ''
      ${numixIcon}/share:/usr/local/share:/usr/share:${config.home.homeDirectory}/.local/share
    '';
  };

  gtk = {
    enable = true;
    font = {
      name = "Inter";
      size = 11;
    };
    theme.name = "gruvbox";
    iconTheme = {
      name = "Numix";
      package = pkgs.numix-icon-theme;
    };
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
  };

  fonts.fontconfig.enable = true;

  programs.git = {
    enable = true;
    userName = "elianiva";
    userEmail = "dicha.arkana03@gmail.com";
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
    config.theme = "base16";
  };

  home.file = {
    ".config/alacritty".source      = link ./alacritty;
    ".config/awesome".source        = link ./awesome;
    ".config/nvim".source           = link ./nvim;
    ".config/lf".source             = link ./lf;
    ".config/picom.conf".source     = link ./misc/picom.conf;
    ".config/aliasrc".source        = link ./misc/aliasrc;
    ".config/pacman".source         = link ./pacman;
    ".config/rofi".source           = link ./rofi;
    ".config/starship.toml".source  = link ./misc/starship.toml;
    ".config/zathurarc".source      = link ./misc/zathurarc;
    ".tmux.conf".source             = link ./tmux/.tmux.conf;
    ".scripts".source               = link ./scripts;
    ".profile".source               = link ./misc/.profile;
    ".pam_environment".source       = link ./misc/.pam_environment;
    ".xinitrc".source               = link ./misc/.xinitrc;
    ".xprofile".source              = link ./misc/.xprofile;
    ".Xresources".source            = link ./misc/.Xresources;
    ".zprofile".source              = link ./zsh/.zprofile;
    ".zshenv".source                = link ./zsh/.zshenv;
    ".zshrc".source                 = link ./zsh/.zshrc;

    # These stuff are not used ATM
    # ".config/sway".source    = link ./sway;
    # ".config/wofi".source    = link ./wofi;
    # ".config/waybar".source  = link ./waybar;
    # ".config/sxhkd".source   = link ./sxhkd;
    # ".config/mako".source    = link ./mako;
    # ".config/bspwm".source   = link ./bspwm;
    # ".config/i3".source      = link ./i3;
    # ".config/polybar".source = link ./polybar;
    # ".config/openbox".source = link ./openbox;
    # ".config/qt5ct".source   = link ./qt5ct;
  };

  services.clipmenu.enable = true;
}

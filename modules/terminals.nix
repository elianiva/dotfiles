{ pkgs, config, ... }:
let
  link = config.lib.file.mkOutOfStoreSymlink;
  dotfiles = "${config.home.homeDirectory}/.dotfiles";
in
{
  programs.wezterm = {
    enable = true;
    package = config.lib.nixGL.wrap pkgs.wezterm;
  };

  # NOTE(elianiva): as a backup in case wezterm got borked
  programs.kitty = {
    enable = true;
    package = config.lib.nixGL.wrap pkgs.kitty;
    font = {
      name = "JetBrainsMono Nerd Font";
      size = 12;
    };
    settings = {
      adjust_line_height = "140%";
      box_drawing_scale = "0.001, 0.5, 1, 1.75";

      enable_audio_bell = "no";
      window_padding_width = 2;
      background_opacity = 1;
      tab_bar_style = "fade";
      allow_remote_control = "yes";
      hide_window_decorations = "no";
    };
    keybindings = {
      "ctrl+shift+w" = "no-op";
      "alt+shift+k" = "change_font_size all +1.0";
      "alt+shift+j" = "change_font_size all -1.0";
      "alt+v" = "paste_from_clipboard";
      "alt+c" = "copy_to_clipboard";
      "alt+k" = "combine : send_text application k : scroll_line_up";
      "alt+j" = "combine : send_text application j : scroll_line_down";
      "alt+u" = "scroll_page_up";
      "alt+d" = "scroll_page_down";
      "kitty_mod+t" = "new_tab_with_cwd";
      "alt+space" = "no_op";
      "alt+1" = "goto_tab 1";
      "alt+2" = "goto_tab 2";
      "alt+3" = "goto_tab 3";
      "alt+4" = "goto_tab 4";
      "alt+5" = "goto_tab 5";
      "alt+6" = "goto_tab 6";
      "alt+n" = "next_tab";
      "alt+p" = "previous_tab";
    };
  };

  # I don't want to rebuild everytime i change these configs
  home.file = {
    ".config/wezterm" = {
      source = link "${dotfiles}/wezterm";
      recursive = true;
    };
  };
}

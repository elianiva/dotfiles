# Nothing feels like ~

![Preview](preview.png)

[arch-link]: https://archlinux.org/
[awesome-link]: https://github.com/awesomewm/awesome
[i3-link]: https://github.com/i3/i3
[bspwm-link]: https://github.com/baskerville/bspwm
[openbox-link]: https://github.com/danakj/openbox
[neovim-link]: https://github.com/neovim/neovim
[alacritty-link]: https://github.com/alacritty/alacritty
[zsh-link]: http://www.zsh.org/
[zinit-link]: https://github.com/zdharma/zinit
[starship-link]: https://starship.rs/
[dunst-link]: https://github.com/dunst-project/dunst
[pcmanfm-link]: https://github.com/lxde/pcmanfm
[lf-link]: https://github.com/gokcehan/lf
[picom-link]: https://github.com/yshui/picom
[mpd-link]: https://github.com/MusicPlayerDaemon/MPD
[ncmpcpp-link]: https://github.com/ncmpcpp/ncmpcpp
[mpv-link]: https://github.com/mpv-player/mpv
[ncspot-link]: https://github.com/hrkfdn/ncspot
[polybar-link]: https://github.com/polybar/polybar
[rofi-link]: https://github.com/davatorium/rofi
[pacman-link]: https://wiki.archlinux.org/index.php/pacman
[paru-link]: https://github.com/Morganamilo/paru
[zinit-link]: https://github.com/zdharma/zinit
[sxhkd-link]: https://github.com/baskerville/sxhkd
[tmux-link]: https://github.com/tmux/tmux

---
### Some Details
- **Operating System:** [Archlinux][arch-link]
- **Window Manager:**
  - [AwesomeWM][awesome-link]
  - [BSPWM][bspwm-link] (no longer using)
  - [i3][i3-link] (no longer using)
  - [Openbox][openbox-link] (no longer using)
- **Bar:** [Polybar][polybar-link] (no longer using)
- **Text Editor:** [Neovim][neovim-link]
- **Terminal:** [Alacritty][alacritty-link]
- **Shell:** [ZSH][zsh-link]
- **Shell Prompt:** [Starship][starship-link]
- **Package/Plugin Manager:**
  - [Pacman][pacman-link] (main package manager)
  - [Paru][paru-link] (AUR helper)
  - [Zinit][zinit-link] (ZSH plugin manager)
- **Launcher:** [Rofi][rofi-link]
- **Notification Daemon:** [Dunst][dunst-link] (no longer using)
- **File Manager:**
  - [Pcmanfm][pcmanfm-link] (GUI)
  - [lf][lf-link] (CLI)
- **Compositor:**
  - [picom][picom-link]
- **Music Player:**
  - [MPD][mpd-link] (no longer using)
  - [ncmpcpp][ncmpcpp-link] (no longer using)
  - [nscpot][ncspot-link] (no longer using)
- **Video Player:** [MPV][mpv-link]
- **Hotkey Daemon:** [sxhkd][sxhkd-link] (no longer using)
- **Terminal Multiplexer:** [tmux][tmux-link]

---
### AwesomeWM config structure

**.config/awesome**
- **rc.lua** - The entry point of my entire AwesomeWM config
- **keybinds**
  - **bindtotags.lua** - Tag related keybinds (moving between tags, etc)
  - **clientbuttons.lua** - Client (window) related mouse bindings (focusing, raising, etc)
  - **clientkeys.lua** - Client (window) related keybinds (closing, pinning, etc)
  - **globalkeys.lua** - Global keybinds (move focus, open launcher, etc)
  - **mediakeys.lua** - Media related keybinds (next song, pause, etc)
- **main**
  - **autostart.lua** - Autostart stuff
  - **error-handling.lua** - Handles error if I mess up
  - **exitscreen.lua** - Fancy-ish exit screen
  - **helpers.lua** - Some helpers
  - ***json.lua*** - JSON stuff. credit: [rxi/json.lua][https://github.com/rxi/json.lua]
  - **layouts.lua** - Define layout
  - **menu.lua** - Define corner menu
  - **rules.lua** - Define client rules
  - **signals.lua** - Define signals (change border, no offscreen, etc)
  - **tags.lua** - Define tags
  - **titlebar.lua** - Define client titlebar
  - **variables.lua** - Place where I store all of my poorly named variables
  - **volume-widget** - Handy volume widget like the one you see on Android
- **statusbar**
  - **init.lua** - Entry point of statusbar config
  - **modules**
    - **battery** - Battery module
    - **clock** - Clock module with calendar
    - **cpu** - CPU module
    - **memory** - Memory module
    - **netspeed** - Network speed module (upload and download)
    - **playerctl** - Playerctl module (mostly using this for Spotify)
    - **temp** - Temperature module
    - **todo** - I never actually finish my todo list lmao
    - **volume** - Volume module which you can scroll up or down
    - **launcher.lua** - Launch stuff, mostly using this because of the logo in the corner
    - **systray.lua** - System tray
    - **taglist.lua** - I need to see em' taglist
- **themes**
  - **main**
    - **colours.lua** - Place where I define colours
    - **elements.lua** - Place where I define variables for the theme
    - **icons** - I actually can't remember what this is, I think it's the arrow thingy, idk
    - **img** - Some images like wallpaper and whatnot
    - **naughty.lua** - ( ͡° ͜ʖ ͡°) | It's just the notification widget config, actually
    - **theme.lua** - Place where I duct-tape all my theme files

### Neovim config structure

**.config/nvim**
- **init.lua** - Entry point of my Neovim config
- **after**
  - **ftplugin.vim** - Some autocmds that need to be run *after* loading all runtime stuff
  - **indent**
    - **svelte.vim** - Svelte indent
  - **indent.vim** - Indent override
  - **queries**
    - **css**
      - **highlights.scm** - I prefer my own version of css highlights
    - **java**
      - **injections.scm** - Inject JSdoc to Javadoc
- **data**
  - **plenary**
    - **filetypes**
      - **builtin.lua** - Define filetypes for Plenary
- **lua**
  - **modules**
    - **\_appearances.lua** - Some colourscheme overrides live here
    - **lsp**
      - **init.lua** - Entry point of my Neovim LSP config
      - **\_diagnostic.lua** - LSP diagnostic stuff
      - **\_mappings.lua** - LSP specific mappings
    - **\_opts.lua** - Temporary solution until [#13479](https://github.com/neovim/neovim/pull/13479), I stole this from [tjdevries/config_manager](https://github.com/tjdevries/config_manager/blob/master/xdg_config/nvim/lua/tj/globals/opt.lua)
    - **\_others.lua** - Other stuff, idk
    - **\_settings.lua** - Some settings like `set stuff=true`, etc
    - **\_statusline.lua** - My custom statusline lives here
    - **\_util.lua** - Some utility functions
    - **\_mappings.lua** - General mappings
  - **plugins**
    - **\_bufferline.lua** - nvim-bufferline config
    - **\_compe.lua** - nvim-compe config
    - **\_emmet.lua** - Emmet config
    - **\_firenvim.lua** - Firenvim config
    - **\_formatter.lua** - formatter.nvim config
    - **\_gitsigns.lua** - gitsigns.nvim config
    - **\_kommentary.lua** - kommentary config
    - **\_nvimtree.lua** - nvim-tree.lua config
    - **\_packer.lua** - packer.nvim config
    - **\_snippets.lua** - snippets stuff, I barely use it though
    - **\_telescope.lua** - telescope.nvim config
    - **\_treesitter.lua** - nvim-treesitter and its module configuration
- **plugin**
  - **packer\_compiled.vim** - Compiled stuff from packer, I probably should gitignore this
  - **snippets**
    - **global.json** - Global snippets
    - **go.json** - Golang snippets
- **spell**
  - **en.utf-8.add** - Expecto Patronum!
  - **en.utf-8.add.spl** - Wingardium Leviosa!

#!/bin/sh

export EDITOR="nvim"
export DOTS="/home/elianiva/repos/dotfiles"
export TERMINAL="kitty"
export CC="gcc"
export CM_LAUNCHER="rofi"
export CM_SELECTIONS="clipboard"
export FZF_DEFAULT_COMMAND='rg --files --no-ignore --ignore-file ".gitignore"'
export SKIM_DEFAULT_COMMAND='rg --files --no-ignore --ignore-file ".gitignore"'
export QT_QPA_PLATFORMTHEME="qt5ct"
export QT_AUTO_SCREEN_SCALE_FACTOR=0
export QT_FONT_DPI=80
export GTK2_RC_FILES="$HOME/.gtkrc-2.0"
export GOPATH="$HOME/.local/go"
export GOBIN="$HOME/.local/go/bin"
# export XDG_DATA_DIRS="$HOME/.nix-profile/share:/usr/share:/usr/local/share:$HOME/.local/share:$XDG_DATA_DIRS"

# PATH stuff
export PATH="$HOME/.scripts:$PATH"
export PATH="$HOME/.local/bin:$PATH"
export PATH="$HOME/.deno/bin:$PATH"
export PATH="$HOME/.bun/bin:$PATH"
export PATH="$HOME/.config/composer/vendor/bin:$PATH"
export PATH="$HOME/.local/go/bin:$PATH"
export PATH="$HOME/.pub-cache/bin:$PATH"
export PATH="$HOME/.fnm:$PATH"
export PATH="$HOME/.pub-cache/bin:$PATH"
export PATH="$HOME/.cargo/bin:$PATH"
export PATH="$HOME/.dotnet/tools:$PATH"

# export JAVA_OPTS="-XX:+IgnoreUnrecognizedVMOptions"
# export JAVA_HOME="/usr/lib/jvm/java-8-openjdk"

# required if java is installed from nix
# unset JAVA_OPTS
# export _JAVA_OPTIONS="-Dawt.useSystemAAFontSettings=on -Dswing.aatext=true"
# export _JAVA_AWT_WM_NONREPARENTING=1

# Flutter stuff
# export FLUTTER_ROOT="$ANDROID_HOME/flutter"
# export ANDROID_HOME="$HOME/Dev/android"
# export PATH="$ANDROID_HOME/cmdline-tools/latest/bin:$PATH"
# export PATH="$ANDROID_HOME/flutter/bin:$PATH"
# export PATH="$ANDROID_HOME/emulator:$PATH"
# export PATH="$ANDROID_HOME/platform-tools/:$PATH"
export CHROME_EXECUTABLE="/usr/bin/brave"

# Fcitx5 Stuff
export GLFW_IM_MODULE="ibus"
export GTK_IM_MODULE="fcitx"
export QT_IM_MODULE="fcitx"
export XMODIFIERS="@im=fcitx"
export SDL_IM_MODULE="fcitx"
export IBUS_USE_PORTAL=1

# Tidy up stuff
export LESSHISTFILE="${XDG_CONFIG_HOME}less/history"
export LESSKEY="${XDG_CONFIG_HOME}less/keys"
export ICEAUTHORITY="${XDG_CACHE_HOME}ICEauthority"

export FLYCTL_INSTALL="/home/elianiva/.fly"
export PATH="$FLYCTL_INSTALL/bin:$PATH"

# gpg stuff
export GPG_TTY=$(tty)

source $HOME/.nix-profile/etc/profile.d/hm-session-vars.sh

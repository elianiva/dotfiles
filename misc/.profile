#!/bin/sh

export EDITOR="nvim"
export CC="gcc"

export FZF_DEFAULT_COMMAND='rg --files --no-ignore --ignore-file ".gitignore"'
export SKIM_DEFAULT_COMMAND='rg --files --no-ignore --ignore-file ".gitignore"'

export NODE_COMPILE_CACHE="$HOME/.cache/nodejs-compile-cache"

export GOPATH="$HOME/.local/go"
export GOBIN="$HOME/.local/go/bin"

# pnpm
export PNPM_HOME="$HOME/.local/share/pnpm"
if [ "$(uname -s)" = "Darwin" ]; then
  export PNPM_HOME="$HOME/Library/pnpm"
fi
case ":$PATH:" in
  *":$PNPM_HOME:") ;;
  *) export PATH="$PNPM_HOME:$PATH" ;;
esac

# common paths
export PATH="$HOME/.local/bin:$PATH"
export PATH="$HOME/.deno/bin:$PATH"
export PATH="$HOME/.bun/bin:$PATH"
export PATH="$HOME/.config/composer/vendor/bin:$PATH"
export PATH="$HOME/.local/go/bin:$PATH"
export PATH="$HOME/.pub-cache/bin:$PATH"
export PATH="$HOME/.cargo/bin:$PATH"
export PATH="$HOME/.radicle/bin:$PATH"

# vite-plus
. "$HOME/.vite-plus/env"

export GPG_TTY=$(tty)

# tidy up xdg paths
export LESSHISTFILE="${XDG_CONFIG_HOME:-$HOME/.config}/less/history"
export LESSKEY="${XDG_CONFIG_HOME:-$HOME/.config}/less/keys"
export ICEAUTHORITY="${XDG_CACHE_HOME:-$HOME/.cache}/ICEauthority"

case "$(uname -s)" in
  Darwin)
    export PATH="/opt/homebrew/bin:$PATH"
    export QT_AUTO_SCREEN_SCALE_FACTOR=0
    export QT_FONT_DPI=80
    export ANDROID_HOME="$HOME/Library/Android/sdk"
    export PATH="$ANDROID_HOME/cmdline-tools/latest/bin:$PATH"
    export PATH="$ANDROID_HOME/platform-tools:$PATH"
    export PATH="$ANDROID_HOME/emulator:$PATH"
    ;;

  Linux)
    export QT_QPA_PLATFORMTHEME="qt5ct"
    export QT_AUTO_SCREEN_SCALE_FACTOR=0
    export QT_FONT_DPI=80
    export GTK2_RC_FILES="$HOME/.gtkrc-2.0"
    export GLFW_IM_MODULE="ibus"
    export GTK_IM_MODULE="fcitx"
    export QT_IM_MODULE="fcitx"
    export XMODIFIERS="@im=fcitx"
    export SDL_IM_MODULE="fcitx"
    export IBUS_USE_PORTAL=1
    ;;
esac

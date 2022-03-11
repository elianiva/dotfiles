#!/bin/sh

# env variables from home manager
# source "$HOME/.nix-profile/etc/profile.d/hm-session-vars.sh"

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

# Nix stuff
# export NIX_PATH=$HOME/.nix-defexpr/channels${NIX_PATH:+:}$NIX_PATH

# PATH stuff
export PATH="$HOME/.scripts:$PATH"
export PATH="$HOME/.local/bin:$PATH"
export PATH="$HOME/.deno/bin:$PATH"
export PATH="$HOME/.config/composer/vendor/bin:$PATH"
export PATH="$HOME/.local/go/bin:$PATH"
export PATH="$HOME/.pub-cache/bin:$PATH"
export PATH="$HOME/.fnm:$PATH"
export PATH="$HOME/.pub-cache/bin:$PATH"
export PATH="$HOME/.cargo/bin:$PATH"

# export JAVA_OPTS="-XX:+IgnoreUnrecognizedVMOptions"
# export JAVA_HOME="/usr/lib/jvm/java-8-openjdk"

# required if java is installed from nix
unset JAVA_OPTS
export _JAVA_OPTIONS="-Dawt.useSystemAAFontSettings=on -Dswing.aatext=true"
export _JAVA_AWT_WM_NONREPARENTING=1
export ANDROID_SDK_ROOT="/opt/android-sdk"
export ANDROID="$HOME/Dev/android"

# # Flutter stuff
# export PATH="/opt/android-sdk/cmdline-tools/latest/bin:$PATH"
# export PATH="$HOME/Dev/android/flutter/bin:$PATH"
# export PATH="$ANDROID_HOME/emulator:$PATH"
# export PATH="$ANDROID_HOME/platform-tools/:$PATH"
# export PATH="$ANDROID_HOME/tools/bin/:$PATH"
# export PATH="$ANDROID_HOME/tools/:$PATH"

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

export LF_ICONS="\
tw= :\
st= :\
ow= :\
dt= :\
di= :\
fi= :\
ln= :\
or= :\
ex= :\
*.c= :\
*.cc= :\
*.clj= :\
*.coffee= :\
*.cpp= :\
*.css= :\
*.d= :\
*.dart= :\
*.erl= :\
*.exs= :\
*.fs= :\
*.go= :\
*.h= :\
*.hh= :\
*.hpp= :\
*.hs= :\
*.html= :\
*.java= :\
*.jl= :\
*.js= :\
*.json= :\
*.lua= :\
*.md= :\
*.php= :\
*.pl= :\
*.pro= :\
*.py= :\
*.rb= :\
*.rs= :\
*.scala= :\
*.ts= :\
*.vim= :\
*.cmd= :\
*.ps1= :\
*.sh= :\
*.bash= :\
*.zsh= :\
*.fish= :\
*.tar= :\
*.tgz= :\
*.arc= :\
*.arj= :\
*.taz= :\
*.lha= :\
*.lz4= :\
*.lzh= :\
*.lzma= :\
*.tlz= :\
*.txz= :\
*.tzo= :\
*.t7z= :\
*.zip= :\
*.z= :\
*.dz= :\
*.gz= :\
*.lrz= :\
*.lz= :\
*.lzo= :\
*.xz= :\
*.zst= :\
*.tzst= :\
*.bz2= :\
*.bz= :\
*.tbz= :\
*.tbz2= :\
*.tz= :\
*.deb= :\
*.rpm= :\
*.jar= :\
*.war= :\
*.ear= :\
*.sar= :\
*.rar= :\
*.alz= :\
*.ace= :\
*.zoo= :\
*.cpio= :\
*.7z= :\
*.rz= :\
*.cab= :\
*.wim= :\
*.swm= :\
*.dwm= :\
*.esd= :\
*.jpg= :\
*.jpeg= :\
*.mjpg= :\
*.mjpeg= :\
*.gif= :\
*.bmp= :\
*.pbm= :\
*.pgm= :\
*.ppm= :\
*.tga= :\
*.xbm= :\
*.xpm= :\
*.tif= :\
*.tiff= :\
*.png= :\
*.svg= :\
*.svgz= :\
*.mng= :\
*.pcx= :\
*.mov=辶:\
*.mpg=辶:\
*.mpeg=辶:\
*.m2v=辶:\
*.mkv=辶:\
*.webm=辶:\
*.ogm=辶:\
*.mp4=辶:\
*.m4v=辶:\
*.mp4v=辶:\
*.vob=辶:\
*.qt=辶:\
*.nuv=辶:\
*.wmv=辶:\
*.flc=辶:\
*.avi=辶:\
*.asf= :\
*.rm= :\
*.rmvb= :\
*.fli= :\
*.flv= :\
*.gl= :\
*.dl= :\
*.xcf= :\
*.xwd= :\
*.yuv= :\
*.cgm= :\
*.emf= :\
*.ogv= :\
*.ogx= :\
*.aac= :\
*.au= :\
*.flac= :\
*.m4a= :\
*.mid= :\
*.midi= :\
*.mka= :\
*.mp3= :\
*.mpc= :\
*.ogg= :\
*.ra= :\
*.wav= :\
*.oga= :\
*.opus= :\
*.spx= :\
*.xspf= :\
*.pdf= :\
*.nix= :\
"

export FLYCTL_INSTALL="/home/elianiva/.fly"
export PATH="$FLYCTL_INSTALL/bin:$PATH"

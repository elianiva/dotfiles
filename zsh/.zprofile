#!/bin/sh
source ~/.profile

## automatically login to WM
if [[ -z $DISPLAY ]] && [[ $(tty) = /dev/tty1 ]]; then
  # export XDG_CURRENT_DESKTOP=sway
  # export XDG_SESSION_TYPE=wayland
  # export QT_QPA_PLATFORMTHEME=wayland
  # export QT_QPA_PLATFORM=wayland
  # export MOZ_ENABLE_WAYLAND=1
  # export GDK_BACKEND=wayland
  exec dbus-launch startx;
elif [[ -z $DISPLAY ]] && [[ $(tty) = /dev/tty2 ]]; then
  export XDG_SESSION_TYPE=wayland
  export QT_QPA_PLATFORMTHEME=wayland
  export QT_QPA_PLATFORM=wayland
  export MOZ_ENABLE_WAYLAND=1
  export GDK_BACKEND=wayland
  # exec sway;
  exec dbus-run-session gnome-session
  # exec dbus-run-session startplasma-wayland
fi

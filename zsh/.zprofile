#!/bin/sh
source ~/.profile

## automatically login to WM
if [[ -z $DISPLAY ]] && [[ $(tty) = /dev/tty1 ]]; then
  export XDG_CURRENT_DESKTOP=sway
  export XDG_SESSION_TYPE=wayland
  export QT_QPA_PLATFORMTHEME=wayland
  export MOZ_ENABLE_WAYLAND=1
  export GDK_BACKEND=wayland
  exec sway;
elif [[ -z $DISPLAY ]] && [[ $(tty) = /dev/tty2 ]]; then
  exec dbus-launch startx;
fi


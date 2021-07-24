#!/bin/sh
source ~/.profile

light -S 40 # set brightness
xset -b # remove annoying bell
xset r rate 300 50 # gotta go fast
fcitx5 --replace -d & # japanese input method using fcitx-mozc
picom --experimental-backends &

export $(systemctl --user show-environment | grep DBUS_SESSION_BUS_ADDRESS)
exec dbus-launch --sh-syntax --exit-with-session awesome
# exec dbus-launch startplasma-x11

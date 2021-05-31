#!/bin/sh
source ~/.profile

light -S 40 # set brightness
xset -b # remove annoying bell
xset r rate 300 50 # gotta go fast
flameshot &
fcitx5 & # japanese input method using fcitx-mozc
picom --experimental-backends &

dbus-launch --exit-with-session

exec awesome
# exec xmonad
# exec dbus-launch startplasma-x11

#!/bin/sh
source ~/.profile

light -S 40 # set brightness
xset -b # remove annoying bell
xset r rate 300 50 # gotta go fast
flameshot &
fcitx5 --replace & # japanese input method using fcitx-mozc
setxkbmap -option caps:escape &
picom --experimental-backends &

dbus-launch --exit-with-session

exec awesome
# exec dbus-launch startplasma-x11

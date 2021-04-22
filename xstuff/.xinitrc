#!/bin/sh
source ~/.profile

light -S 40 # set brightness
setxkbmap -option caps:none
xset -b # remove annoying bell
xset r rate 300 50 # gotta go fast
flameshot &
fcitx5 & # japanese input method using fcitx-mozc

dbus-launch --exit-with-session

pipewire &

exec awesome
# exec dbus-launch startplasma-x11

#!/bin/sh
source ~/.profile

light -S 40 # set brightness
setxkbmap -option caps:none
xset -b # remove annoying bell
xset r rate 300 50 # gotta go fast
fcitx & # japanese input method using fcitx-mozc

exec dbus-launch awesome

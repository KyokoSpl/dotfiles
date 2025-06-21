#!/bin/sh

xrdb merge ~/.Xresources &
lxsession &
xbacklight -set 100 &
xset r rate 200 50 &
picom &
volumeicon &
  bash ~/.screenlayout/standart.sh &
nitrogen --restore &
dunst -conf ~/.config/dunst/dunstrc.d/50-theme.conf &
discord &
blueman-applet &
nm-applet &
caffeine-indicator &
dash ~/.config/chadwm/scripts/bar.sh &
while type chadwm >/dev/null; do chadwm && continue || break; done

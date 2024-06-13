#!/bin/sh

xrdb merge ~/.Xresources &
lxsession &
xbacklight -set 100 &
xset r rate 200 50 &
picom &
volumeicon &
bash ~/.screenlayout/workstandart.sh &
nitrogen --restore &
dunst &
# discord &
teams-for-linux &
blueman-applet &
kdeconnect-indicator &
nm-applet &
caffeine-indicator &


dash ~/.config/chadwm/scripts/bar.sh &
while type chadwm >/dev/null; do chadwm && continue || break; done

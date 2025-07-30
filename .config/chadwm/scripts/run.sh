#!/bin/sh

xrdb merge ~/.Xresources &
lxsession &
xbacklight -set 100 &
xset r rate 200 50 &
picom &
volumeicon &
gnome-keyring-daemon --start --components=secrets
/usr/lib/polkit-gnome/polkit-gnome-authentication-agent-1 || /usr/libexec/polkit-gnome-authentication-agent-1
bash ~/.screenlayout/standart.sh &
nitrogen --restore &
betterlockscreen -u ~/walls/dcbanner_von_josh.jpg &
dunst -conf ~/.config/dunst/dunstrc.d/50-theme.conf &
discord &
blueman-applet &
nm-applet &
caffeine-indicator &
dash ~/.config/chadwm/scripts/bar.sh &
while type chadwm >/dev/null; do chadwm && continue || break; done

#!/bin/sh

xrdb merge ~/.Xresources &
lxsession &
xbacklight -set 100 &
xset r rate 200 50 &
picom &
gnome-keyring-daemon --start --components=secrets
/usr/lib/polkit-gnome/polkit-gnome-authentication-agent-1 || /usr/libexec/polkit-gnome-authentication-agent-1
bash ~/.screenlayout/new_desk.sh &
nitrogen --restore &
bash ~/.config/chadwm/scripts/correct_mouse.sh &
betterlockscreen -u ~/walls/dcbanner_von_josh.jpg &
dunst -conf ~/.config/dunst/dunstrc.d/50-theme.conf &
blueman-applet &
nm-applet &
dash ~/.config/chadwm/scripts/bar.sh &
while type chadwm >/dev/null; do chadwm && continue || break; done

#!/bin/sh

if [ "$(setxkbmap -query | awk '/layout/{print $2}')" = "us" ]; then
   riverctl keyboard-layout de
   notify-send "layout change to de"
else
   riverctl keyboard-layout us
   notify-send "layout change to us"
fi

#!/bin/sh

if [ "$(setxkbmap -query | awk '/layout/{print $2}')" = "us" ]; then
   setxkbmap -layout de
   notify-send "layout change to de"
else
   setxkbmap -layout us
   notify-send "layout change to us"
fi



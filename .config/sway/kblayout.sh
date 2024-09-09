#!/bin/sh

# Define the layouts you want to toggle between
layout_us="us"
layout_de="de"

# Get the current layout using swaymsg
current_layout=$(swaymsg -t get_inputs | grep -m 1 "xkb_active_layout_name" | awk -F '"' '{print $4}')

# Switch the layout based on the current layout
if [ "$current_layout" = "English (US)" ]; then
    swaymsg input "*" xkb_layout $layout_de
else
    swaymsg input "*" xkb_layout $layout_us
fi


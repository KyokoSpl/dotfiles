#!/bin/bash

# Set the name of the screen you're checking for
TARGET_SCREEN="DP-2-2"

# Set the paths to the scripts you want to run
SCRIPT_IF_CONNECTED="~/.screenlayout/desktop.sh"
SCRIPT_IF_DISCONNECTED="~/.screenlayout/on-go.sh"

# Check if the screen is connected
if xrandr | grep -q "^$TARGET_SCREEN connected"; then
    echo "$TARGET_SCREEN is connected."
    bash "$SCRIPT_IF_CONNECTED"
else
    echo "$TARGET_SCREEN is not connected."
    bash "$SCRIPT_IF_DISCONNECTED"
fi


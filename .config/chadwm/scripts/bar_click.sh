#!/bin/dash

# Simple click handler for volume widget
# This script is called by the bar when volume is clicked

# Toggle mute when volume widget is clicked
pamixer --toggle-mute

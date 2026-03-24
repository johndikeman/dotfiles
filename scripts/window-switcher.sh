#!/usr/bin/env bash

# Get list of windows with their addresses, titles, and classes
# We filter out windows that don't have a title or are special
windows=$(hyprctl clients -j | jq -r '.[] | select(.title != "") | "\(.address) \(.class): \(.title)"')

# Use wofi to select a window
selected=$(echo "$windows" | wofi --dmenu --prompt "Switch to..." --cache-file /dev/null | awk '{print $1}')

# Focus the selected window
if [ -n "$selected" ]; then
    hyprctl dispatch focuswindow address:"$selected"
fi

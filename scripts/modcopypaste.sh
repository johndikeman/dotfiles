#!/bin/sh
    
action=$1
terminal_class=$2

active_class=$(hyprctl activewindow -j | jq -r '.class')

if [ "$action" = "copy" ]; then
		key="c"
else
		key="v"
fi

active_class_lower=$(echo "$active_class" | tr '[:upper:]' '[:lower:]')
terminal_class_lower=$(echo "$terminal_class" | tr '[:upper:]' '[:lower:]')

if [ "$active_class_lower" = "$terminal_class_lower" ]; then
		mods="CTRL + SHIFT"
else
		mods="CTRL"
fi

# Send the shortcut using down/up to avoid stuck keys
hyprctl dispatch "hl.dispatch(hl.dsp.send_key_state({mods = '$mods', key = '$key', state = 'down'}))"
hyprctl dispatch "hl.dispatch(hl.dsp.send_key_state({mods = '$mods', key = '$key', state = 'up'}))"

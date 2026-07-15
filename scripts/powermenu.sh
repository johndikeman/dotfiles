DISPLAY_NAMES=('logout' 'power off' 'reboot' 'suspend')
COMMANDS=('hyprshutdown' 'systemctl poweroff' 'systemctl reboot' 'systemctl suspend')

MENU_ITEMS=()
for i in "${!DISPLAY_NAMES[@]}"; do
  MENU_ITEMS+=("${DISPLAY_NAMES[i]}")
done

CHOICE=$(printf '%s\n' "${MENU_ITEMS[@]}" | wofi --show dmenu --prompt "Choose an action")

# Match selection and run command
for i in "${!DISPLAY_NAMES[@]}"; do
  if [[ "${DISPLAY_NAMES[i]}" == "$CHOICE" ]]; then
    eval "${COMMANDS[i]}"
    break
  fi
done


# brightness script, takes device + increment (%) as argument
# check current brightness value
# inc/dec by increment
# calculate %
# display notification with updated percentage

DEVICE = $1
INCREMENT = $2

CURRENT_BRIGHTNESS = $(brightnessctl --device=$DEVICE get)
MAX_BRIGHTNESS = $(brightnessctl --device=$DEVICE max)
BRIGHTNESS_INC = $(echo "scale 2; $MAX_BRIGHTNESS * $INCREMENT" | bc)
NEW_BRIGHTNESS = $(echo "$CURRENT_BRIGHTNESS + $BRIGHTNESS_INC" | bc)
NEW_BRIGHTNESS_PERCENTAGE = $(echo "$NEW_BRIGHTNESS / $MAX_BRIGHTNESS" | bc)

brightnessctl --device=$DEVICE set NEW_BRIGHTNESS

notify-send "🔔 %$NEW_BRIGHTNESS_PERCENTAGE"

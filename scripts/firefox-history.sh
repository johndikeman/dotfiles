#!/usr/bin/env bash

# Find firefox profile
# Often it's something like xxxxxxxx.default-release
PROFILE_DIR=$(find "$HOME/.mozilla/firefox/" -maxdepth 1 -type d -name "*.default*" | head -n 1)

if [ -z "$PROFILE_DIR" ]; then
    notify-send "Firefox History" "No Firefox profile found"
    exit 1
fi

DB_PATH="$PROFILE_DIR/places.sqlite"

if [ ! -f "$DB_PATH" ]; then
    notify-send "Firefox History" "places.sqlite not found at $DB_PATH"
    exit 1
fi

# Copy database to /tmp to avoid locking issues if Firefox is running
TMP_DB=$(mktemp --suffix=.sqlite)
cp "$DB_PATH" "$TMP_DB"

# Query the database
# We want the most recent 1000 visits
query="SELECT title, url FROM moz_places WHERE title IS NOT NULL AND title != '' ORDER BY last_visit_date DESC LIMIT 1000;"

# Run wofi with the history
# We use wofi in dmenu mode
# The separator ' | ' is used to separate Title and URL
selected=$(sqlite3 -separator ' | ' "$TMP_DB" "$query" | wofi --dmenu --prompt "Firefox History" --cache-file /dev/null)

# Clean up temporary database
rm "$TMP_DB"

# If something was selected, extract the URL and open it
if [ -n "$selected" ]; then
    # The URL is the last part after the last ' | '
    url=$(echo "$selected" | awk -F ' | ' '{print $NF}')
    
    # Open in firefox
    if [ -n "$url" ]; then
        firefox "$url"
    fi
fi

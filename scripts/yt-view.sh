#!/usr/bin/env bash
# Managed by Home Manager via home.nix
CHANNELS_FILE="$HOME/.config/yt-channels.txt"
SUBS_CACHE="$HOME/.config/pipe-viewer/subscribed_channels.txt"

sync_subs() {
    if [[ -f "$CHANNELS_FILE" ]]; then
        # Only sync if the channels file is newer than the cache, or cache doesn't exist
        if [[ ! -f "$SUBS_CACHE" || "$CHANNELS_FILE" -nt "$SUBS_CACHE" ]]; then
            echo "Updating subscriptions from $CHANNELS_FILE..."
            while read -r channel; do
                [[ -z "$channel" || "$channel" =~ ^# ]] && continue
                # We use --subscribe which is idempotent enough
                pipe-viewer --subscribe="$channel" --really-quiet &
            done < "$CHANNELS_FILE"
            wait
        fi
    fi
}

if [[ "$1" == "--select" ]]; then
    # Optional: Select a specific channel from the list
    SELECTED=$(grep -v '^#' "$CHANNELS_FILE" | grep -v '^$' | fzf --prompt="Select Channel: " --reverse)
    [[ -n "$SELECTED" ]] && pipe-viewer --uploads="$SELECTED"
elif [[ $# -gt 0 ]]; then
    # Pass arguments directly to pipe-viewer (e.g. search terms)
    pipe-viewer "$@"
else
    # Default: Show recent videos from all subscriptions
    sync_subs
    pipe-viewer --local-subs
fi

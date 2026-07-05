#!/usr/bin/env bash
# Managed by Home Manager via home.nix
CHANNELS_FILE="$HOME/.config/yt-channels.txt"
SUBS_CACHE="$HOME/.config/pipe-viewer/subscribed_channels.txt"
YTDLP="yt-dlp"

sync_subs() {
    if [[ -f "$CHANNELS_FILE" ]]; then
        # Use a state file to track sync because the subscribed_channels.txt 
        # is modified by pipe-viewer internally.
        local STATE_FILE="$HOME/.config/pipe-viewer/.yt_subs_sync_state"
        
        if [[ ! -f "$STATE_FILE" || "$CHANNELS_FILE" -nt "$STATE_FILE" ]]; then
            echo "Updating subscriptions from $CHANNELS_FILE..."
            # Clear current subscriptions 
            > "$SUBS_CACHE"
            
            while read -r channel; do
                [[ -z "$channel" || "$channel" =~ ^# ]] && continue
                echo "Syncing: $channel"
                
                local TARGET="$channel"
                if [[ "$channel" =~ ^http || "$channel" =~ ^@ ]]; then
                    UCID=$($YTDLP --print channel_id --playlist-items 1 "$channel" 2>/dev/null)
                    [[ -n "$UCID" ]] && TARGET="$UCID"
                fi
                
                pipe-viewer --subscribe="$TARGET" --really-quiet
            done < "$CHANNELS_FILE"
            
            touch "$STATE_FILE"
        fi
    fi
}

if [[ "$1" == "--select" ]]; then
    sync_subs
    # Select from friendly names if available, or URLs
    SELECTED=$(grep -v '^#' "$CHANNELS_FILE" | grep -v '^$' | fzf --prompt="Select Channel: " --reverse)
    [[ -z "$SELECTED" ]] && exit 0

    # Resolve selection to ID for the upload call
    FINAL_TARGET="$SELECTED"
    if [[ "$SELECTED" =~ ^http || "$SELECTED" =~ ^@ ]]; then
        UCID=$($YTDLP --print channel_id --playlist-items 1 "$SELECTED" 2>/dev/null)
        [[ -n "$UCID" ]] && FINAL_TARGET="$UCID"
    fi
    pipe-viewer --api=auto --uploads="$FINAL_TARGET" 
elif [[ $# -gt 0 ]]; then
    pipe-viewer --api=auto "$@" 
else
    sync_subs
    # --local-subs merges the 'uploads' of all channels in subscribed_channels.txt
    pipe-viewer --api=auto --local-subs 
fi

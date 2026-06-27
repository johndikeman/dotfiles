#!/usr/bin/env bash
# Managed by Home Manager via home.nix
CHANNELS_FILE="$HOME/.config/yt-channels.txt"
SUBS_CACHE="$HOME/.config/pipe-viewer/subscribed_channels.txt"
YTDLP="/nix/store/g7r0k2hzm2la41y01hx7pr71v2g2j9k0-yt-dlp-2026.03.17/bin/yt-dlp"

sync_subs() {
    if [[ -f "$CHANNELS_FILE" ]]; then
        # Use a state file to track sync because the subscribed_channels.txt 
        # is modified by pipe-viewer internally.
        local STATE_FILE="$HOME/.config/pipe-viewer/.yt_subs_sync_state"
        
        if [[ ! -f "$STATE_FILE" || "$CHANNELS_FILE" -nt "$STATE_FILE" || "$1" == "--force-sync" ]]; then
            echo "Updating subscriptions from $CHANNELS_FILE..."
            # Clear current subscriptions 
            > "$SUBS_CACHE"
            
            while read -r channel; do
                [[ -z "$channel" || "$channel" =~ ^# ]] && continue
                echo "Syncing: $channel"
                
                local TARGET="$channel"
                if [[ "$channel" =~ ^http || "$channel" =~ ^@ ]]; then
                    # Using --print channel_id is reliable but can be slow for many channels
                    # We background the resolution and subscription to speed it up
                    (
                        UCID=$($YTDLP --print channel_id --playlist-items 1 "$channel" 2>/dev/null)
                        if [[ -n "$UCID" ]]; then
                            # pipe-viewer --subscribe is not thread-safe for the file, 
                            # so we append to a temp file and merge at the end
                            echo "$UCID" >> "$SUBS_CACHE.tmp"
                        fi
                    ) &
                else
                    echo "$channel" >> "$SUBS_CACHE.tmp"
                fi
            done < "$CHANNELS_FILE"
            wait

            # Merge temp file back to SUBS_CACHE using pipe-viewer to get names/metadata
            if [[ -f "$SUBS_CACHE.tmp" ]]; then
                while read -r id; do
                    pipe-viewer --subscribe="$id" --really-quiet
                done < "$SUBS_CACHE.tmp"
                rm "$SUBS_CACHE.tmp"
            fi
            
            touch "$STATE_FILE"
        fi
    fi
}

if [[ "$1" == "--sync" ]]; then
    sync_subs --force-sync
    exit 0
fi

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
    pipe-viewer --player=vlc --api=auto --uploads="$FINAL_TARGET" --order=upload_date
elif [[ $# -gt 0 ]]; then
    pipe-viewer --player=vlc --api=auto "$@" --order=upload_date
else
    sync_subs
    # --local-subs merges the 'uploads' of all channels in subscribed_channels.txt
    pipe-viewer --player=vlc --api=auto --local-subs --order=upload_date
fi

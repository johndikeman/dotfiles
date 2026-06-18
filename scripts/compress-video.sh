#!/usr/bin/env bash

# Compress a video to a target file size using ffmpeg 2-pass encoding.

if [ -z "$1" ]; then
    echo "Usage: $0 <input_file> [target_size_mb]"
    exit 1
fi

INPUT="$1"
TARGET_SIZE_MB=${2:-490}
OUTPUT="${INPUT%.*}_compressed.mp4"

# Get duration in seconds using ffprobe
DURATION=$(ffprobe -v error -select_streams v:0 -show_entries format=duration -of default=noprint_wrappers=1:nokey=1 "$INPUT")

if [ -z "$DURATION" ]; then
    echo "Error: Could not determine duration of $INPUT"
    exit 1
fi

# Calculate total bitrate in kbps (Target size in bits / duration / 1024)
# Using 1024 for binary MB -> KB conversion for safety
TOTAL_BITRATE=$(awk -v size="$TARGET_SIZE_MB" -v dur="$DURATION" 'BEGIN { print (size * 1024 * 8) / dur }')

# Reserve some bitrate for audio (e.g., 128 kbps)
AUDIO_BITRATE=128
VIDEO_BITRATE=$(awk -v total="$TOTAL_BITRATE" -v audio="$AUDIO_BITRATE" 'BEGIN { printf "%d", total - audio }')

echo "Input: $INPUT"
echo "Duration: $DURATION s"
echo "Target Size: $TARGET_SIZE_MB MB"
echo "Calculated Video Bitrate: ${VIDEO_BITRATE}k"

# Pass 1
ffmpeg -y -i "$INPUT" -c:v libx264 -b:v "${VIDEO_BITRATE}k" -pass 1 -an -f mp4 /dev/null

# Pass 2
ffmpeg -y -i "$INPUT" -c:v libx264 -b:v "${VIDEO_BITRATE}k" -pass 2 -c:a aac -b:a "${AUDIO_BITRATE}k" "$OUTPUT"

# Cleanup
rm -f ffmpeg2pass-0.log ffmpeg2pass-0.log.mbtree x264_2pass.log

echo "Compression finished. Output: $OUTPUT"

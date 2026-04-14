DEFAULT_INTERVAL=300 # In seconds

if [ $# -lt 1 ] || [ ! -d "$1" ]; then
	printf "Usage:
	\e[1m%s\e[0m \e[4mDIRECTORY\e[0m [\e[4mINTERVAL\e[0m]
" "$0"
	printf "	Changes the wallpaper to a randomly chosen image in DIRECTORY every
	INTERVAL seconds (or every %d seconds if unspecified).\n" "$DEFAULT_INTERVAL"
	exit 1
fi

DIRECTORY="$1"
INTERVAL="${2:-$DEFAULT_INTERVAL}"
RESIZE_TYPE="crop"

echo "Starting wallpaper changer..."
echo "Directory: $DIRECTORY"
echo "Interval: $INTERVAL seconds"

while true; do
	# Create array of image files
	mapfile -t images < <(find "$DIRECTORY" -type f ! -path '*/.git/*' \
		| grep -iE '\.(jpg|jpeg|png|gif|bmp|tiff|webp)$')
	
	if [ ${#images[@]} -eq 0 ]; then
		echo "No image files found in $DIRECTORY"
		exit 1
	fi
	
	echo "Found ${#images[@]} images"
	
	# Shuffle the array and cycle through images
	for img in $(printf '%s\n' "${images[@]}" | shuf); do
		if [ -f "$img" ]; then
			echo "Setting wallpaper: $img"
			awww img --resize="$RESIZE_TYPE" -t random "$img"
			sleep "$INTERVAL"
		fi
	done
done

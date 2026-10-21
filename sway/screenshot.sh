#!/usr/bin/env bash
# Pick a region, save it in ~/images/ss and copy it to the clipboard.
set -eu

geometry=$(slurp) || exit 0    # Esc cancels without touching the clipboard
shots="$HOME/images/ss"
mkdir -p "$shots"
file=$(mktemp "$shots/$(date +%Y%m%d-%H%M%S)-XXXXXX.png")

if ! grim -g "$geometry" "$file"; then
    rm -f "$file"
    notify-send -a screenshot 'screenshot failed'
    exit 1
fi
# the shot itself is the icon
if wl-copy --type image/png <"$file"; then
    notify-send -a screenshot -i "$file" 'screenshot' 'copied · ~/images/ss'
else
    notify-send -a screenshot -i "$file" 'screenshot, not copied' 'saved in ~/images/ss'
fi

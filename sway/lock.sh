#!/usr/bin/env bash
# Sway and swayidle share this lock command.
# -f forks once locked, which swayidle's before-sleep needs. If the screen is
# already locked, swaylock refuses to lock it twice and exits on its own.
# ring 08 · checking 0c (teal, so it stands out) · wrong 0f · inside 07

exec swaylock -f \
    -i "$HOME/.config/sway/wxp.png" -s fill \
    --indicator-radius 90 --indicator-thickness 8 \
    --ring-color ed286f --ring-ver-color 00b9a3 --ring-wrong-color cb2762 \
    --key-hl-color feedf3 --bs-hl-color cb2762 \
    --line-color 00000000 --separator-color 00000000 \
    --inside-color 352930aa --text-color feedf3

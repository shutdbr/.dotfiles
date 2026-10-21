#!/run/current-system/sw/bin/bash
set -eu

limit=/sys/class/power_supply/BAT0/charge_control_end_threshold
if [[ ${1-} == toggle ]]; then
    enabled=true
    [[ $(<"$limit") -lt 100 ]] && enabled=false
    /run/current-system/sw/bin/busctl --system call org.freedesktop.UPower \
        /org/freedesktop/UPower/devices/battery_BAT0 \
        org.freedesktop.UPower.Device EnableChargeThreshold b "$enabled" >/dev/null
fi
printf '%s\n' "$(<"$limit")"

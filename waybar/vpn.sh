#!/run/current-system/sw/bin/bash
# a closed lock while a NetworkManager VPN is up, an open one when not
if /run/current-system/sw/bin/nmcli -t -f TYPE connection show --active | grep -qxE 'vpn|wireguard|tun'; then
    echo $''
else
    echo $''
fi

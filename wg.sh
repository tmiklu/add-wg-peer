#!/bin/bash

display_help() {
    echo "Usage: $0 [<meno> <ip>]" >&2
    echo "run under root"
    exit 1
}


[ `whoami` == "root" ] || display_help

[ ! -z "$1" ] && [ ! -z $2 ] || display_help

COMPARE=`comm -12 <(echo "10.0.0.$2/32") <(cat /etc/wireguard/wg0.conf | egrep '\/32' | awk -F= '{ print $2 }' | sort)`

if [ ! -z "$COMPARE" ] ; then
  echo "This ip $COMPARE exists!"
  exit 2
fi

wg genkey | tee "$1priv" | wg pubkey > "$1pub"


cat << EOF >> /etc/wireguard/wg0.conf

[Peer]
# $1
PublicKey=`cat "$1pub"`
AllowedIPs=10.0.0.$2/32
EOF

systemctl restart wg-quick@wg0.service

cat << EOF
# Copy this output to end user for wireguard client
[Interface]
PrivateKey = `cat "$1priv"`
Address = 10.0.0.$2/8
DNS = 8.8.8.8

[Peer]
PublicKey = B5EcaClG3J7kKQMsNYMPB/WPhCJP1xvpyqLo+Ye8ZU4=
AllowedIPs = 0.0.0.0/0
Endpoint = 87.197.160.19:5000
PersistentKeepalive = 15
EOF

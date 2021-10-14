#!/bin/bash

# wireguard and iptables install
sudo dnf -y install wireguard-tools
sudo dnf -y install iptables

# generate public and private keys
privatekey="$(wg genkey)"
publickey="$(echo $privatekey | wg pubkey)"

# build server endpoint config
[[ $UID -eq 0 ]] || sudo=sudo
$sudo sh -c 'umask 077; mkdir -p /etc/wireguard; cat > /etc/wireguard/wgserv.conf' <<_EOF
[Interface]
PrivateKey = $privatekey
Address = 10.0.10.1/24
SaveConfig = true
ListenPort = 51280

[Peer]
PublicKey = CLIENT_PUBLICKEY
AllowedIPs = 10.0.10.2/24
_EOF

# bring up server
[[ $UID -eq 0 ]] || sudo=sudo
$sudo sh -c 'wg-quick up wgserv'
sleep 10

# set up NAT routing
sudo sysctl net.ipv4.ip_forward=1
sudo iptables -A FORWARD -i wgserv -j ACCEPT
sudo iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE

# place public file in fedora's home dir
echo $publickey > ~fedora/wg.pubkey
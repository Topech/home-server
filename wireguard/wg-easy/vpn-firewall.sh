#!/bin/sh

ACTION=$1

if [ "$ACTION" = 'add' ]; then
    ACTION_FLAG='-A'
elif [ "$ACTION" = 'delete' ]; then
    ACTION_FLAG='-D'
else
    echo "$0: argument must be 'add' or 'delete'" >&2
    exit 1
fi

# Resolve host.docker.internal to an IP
HOST_IP=$(getent hosts host.docker.internal | awk '{ print $1 }')

# ----
# IPTABLE rules

# ### Send traffic to the docker service's host machine
# (prerouting so its differentiated from normal VPN traffic)
iptables -t nat ${ACTION_FLAG} PREROUTING -i wg0 -d 10.8.0.1 -p tcp \
	-m multiport --dports 22,5985,7074,8687 \
	-j DNAT --to-destination "${HOST_IP}"


# Accept VPN protocol
iptables ${ACTION_FLAG} INPUT -p udp -m udp --dport 51820 -j ACCEPT

# Allow VPN traffic to bridge from VPN network to LAN network
iptables ${ACTION_FLAG} FORWARD -i wg0 -o eth0 -s 10.8.0.0/24 \
	-m multiport --dports 22,5985,7074,8687 \
	-j ACCEPT

# Only allow LAN network into VPN if its related to VPN traffic
iptables ${ACTION_FLAG} FORWARD -i eth0 -o wg \
	-m state --state RELATED,ESTABLISHED -j ACCEPT
iptables ${ACTION_FLAG} FORWARD -i eth0 -o wg \
	-m state --state INVALID -j DROP

# Any VPN traffic out looks like it comes from this docker service
iptables -t nat ${ACTION_FLAG} POSTROUTING -s 10.8.0.0/24 -o eth0 -j MASQUERADE


# drop any unexpected traffic on VPN network
iptables ${ACTION_FLAG} INPUT -i wg0 -j DROP

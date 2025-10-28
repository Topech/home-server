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

# Allow only VPN clients (wg0) to access host 5985 and 22
# iptables ${ACTION_FLAG} INPUT -i wg0 -s 10.8.0.0/24 -d "${HOST_IP}" -p tcp --dport 5985 -j ACCEPT
# iptables ${ACTION_FLAG} INPUT -i wg0 -s 10.8.0.0/24 -d "${HOST_IP}" -p tcp --dport 22 -j ACCEPT
# 
# # DNAT rules (VPN clients can reach host via 10.8.0.1)
# iptables -t nat ${ACTION_FLAG} PREROUTING -i wg0 -d 10.8.0.1 -p tcp --dport 5985 \
#     -j DNAT --to-destination "${HOST_IP}"
# iptables -t nat ${ACTION_FLAG} PREROUTING -i wg0 -d 10.8.0.1 -p tcp --dport 22 \
#     -j DNAT --to-destination "${HOST_IP}"
# 
# # Masquerade and allow VPN
# iptables -t nat ${ACTION_FLAG} POSTROUTING -s 10.8.0.0/24 -o eth0 -j MASQUERADE
# ip6tables -t nat ${ACTION_FLAG} POSTROUTING -s fdcc:ad94:bacf:61a4::cafe:0/112 -o eth0 -j MASQUERADE
# 
# # Allow VPN packets (WireGuard)
# iptables ${ACTION_FLAG} INPUT -p udp --dport 51820 -j ACCEPT
# ip6tables ${ACTION_FLAG} INPUT -p udp --dport 51820 -j ACCEPT
# 
# # Drop any other forwarding from wg0 to the host
# iptables ${ACTION_FLAG} FORWARD -i wg0 -j DROP


# # Forward SSH (22) and CouchDB (5985) from VPN clients to the host
# iptables -t nat ${ACTION_FLAG} PREROUTING -i wg0 -p tcp --dport 22   -j DNAT --to-destination ${HOST_IP}:22
# iptables -t nat ${ACTION_FLAG} PREROUTING -i wg0 -p tcp --dport 5985 -j DNAT --to-destination ${HOST_IP}:5985
# 
# iptables ${ACTION_FLAG} FORWARD -i wg0 -o eth0 -p tcp -d ${HOST_IP} --dport 22   -j ACCEPT
# iptables ${ACTION_FLAG} FORWARD -i wg0 -o eth0 -p tcp -d ${HOST_IP} --dport 5985 -j ACCEPT
# 
# # Masquerade replies so host sends responses back correctly
# # iptables -t nat ${ACTION_FLAG} POSTROUTING -s 10.8.0.0/24 -d ${HOST_IP} -j MASQUERADE
# iptables -t nat ${ACTION_FLAG} POSTROUTING -i wg0 -o eth0 -s 10.8.0.0/24 -d ${HOST_IP} -p tcp --dport 22 -j MASQUERADE
# iptables -t nat ${ACTION_FLAG} POSTROUTING -i wg0 -o eth0 -s 10.8.0.0/24 -d ${HOST_IP} -p tcp --dport 5985 -j MASQUERADE
# 
# # Allow any incoming traffic that originated from VPN
# iptables ${ACTION_FLAG} FORWARD -i eth0 -o wg \
# 	-p tcp -d ${HOST_IP} --dport 22 \
# 	-m state --state RELATED,ESTABLISHED -j ACCEPT
# iptables ${ACTION_FLAG} FORWARD -i eth0 -o wg \
# 	-p tcp -d ${HOST_IP} --dport 5985 \
# 	-m state --state RELATED,ESTABLISHED -j ACCEPT
# 
# # drop any packets that dont match our rules
# iptables -A FORWARD -m state --state INVALID -j DROP



# ----
  
# allow input in
# iptables ${ACTION_FLAG} INPUT -p udp --dport 51820 -j ACCEPT

# iptables ${ACTION_FLAG} FORWARD -i wg0 -o eth0 -p -s 10.8.0.0/24 tcp -j ACCEPT
# iptables ${ACTION_FLAG} FORWARD -i eth0 -o wg0 -p tcp -j ACCEPT

# Any network traffic out looks as if its from this device
# iptables -t nat ${ACTION_FLAG} POSTROUTING -o eth0 -s 10.8.0.0/24 -j MASQUERADE
# iptables -t nat ${ACTION_FLAG} POSTROUTING -i wg0 -o eth0 -s 10.8.0.0/24 -d ${HOST_IP} -j MASQUERADE

# # Allow any incoming traffic that originated from VPN
# # (relies on strict VPN forwarding out regulation)
# iptables ${ACTION_FLAG} FORWARD -i eth0 -o wg \
# 	-m state --state RELATED,ESTABLISHED -j ACCEPT

# iptables -A FORWARD -m state --state INVALID -j DROP

# iptables ${ACTION_FLAG} FORWARD -i eth0 -o wg \
# 	-p tcp -d ${HOST_IP} --dport 22 \
# 	-m state --state RELATED,ESTABLISHED -j ACCEPT
# iptables ${ACTION_FLAG} FORWARD -i eth0 -o wg \
# 	-p tcp -d ${HOST_IP} --dport 5985 \
# 	-m state --state RELATED,ESTABLISHED -j ACCEPT


# ----

iptables -t nat ${ACTION_FLAG} PREROUTING -i wg0 -d 10.8.0.1 -p tcp --dport 22 \
    -j DNAT --to-destination "${HOST_IP}"
iptables ${ACTION_FLAG} INPUT -p udp -m udp --dport 51820 -j ACCEPT


# iptables ${ACTION_FLAG} FORWARD -i wg0 -j ACCEPT
# iptables ${ACTION_FLAG} FORWARD -o wg0 -j ACCEPT
iptables ${ACTION_FLAG} FORWARD -i wg0 -o eth0 -j ACCEPT
iptables ${ACTION_FLAG} FORWARD -i eth0 -o wg0 -j ACCEPT

iptables -t nat ${ACTION_FLAG} POSTROUTING -s 10.8.0.0/24 -o eth0 -j MASQUERADE

# drop any unexpected traffic on VPN network
iptables ${ACTION_FLAG} INPUT -i wg0 -j DROP

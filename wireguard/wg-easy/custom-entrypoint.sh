#!/bin/sh

# Start WireGuard normally
# wg-quick up wg0

# Apply your iptables rules
# NOTE: must be applied to the db, so must have API up
# /vpn-firewall.sh

# Keep container running (or let wg-easy run its original process if needed)
/usr/local/bin/docker-entrypoint.sh "$@"

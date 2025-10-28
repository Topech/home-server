FROM ghcr.io/wg-easy/wg-easy:15

# Copy your firewall script into the container
COPY vpn-firewall.sh /vpn-firewall.sh
RUN chmod +x /vpn-firewall.sh

# Override entrypoint to start WireGuard then apply firewall rules
COPY custom-entrypoint.sh /custom-entrypoint.sh
RUN chmod +x /custom-entrypoint.sh

# override to add vpn firewall in
ENTRYPOINT ["/custom-entrypoint.sh"]

# the standard CMD from ghcr.io/wg-easy/wg-easy:15
CMD ["/usr/bin/dumb-init", "node", "server/index.mjs"]

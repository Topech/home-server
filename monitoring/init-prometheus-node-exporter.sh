#!/bin/bash

# This will install and setup prometheus-node-exporter to expose Host machine data to grafana

# REF:
# - Grafana dash: https://grafana.com/grafana/dashboards/1860-node-exporter-full/

sudo apt install prometheus-node-exporter -y


echo \
add \'–collector.systemd –collector.processes\' to the ARGS= line in \
/etc/default/prometheus-node-exporter to enable full dash capabilities!

#! /bin/bash

set -e


# ensure superuser privileges
if [[ $EUID -ne 0 ]]; then
  echo "Run as root: sudo $0"
  exit 1
fi


apt install -y wireguard

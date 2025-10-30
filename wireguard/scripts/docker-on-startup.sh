#! /bin/bash

# exit on failure
set -e


# ensure superuser privileges
if [[ $EUID -ne 0 ]]; then
  echo "Run as root: sudo $0"
  exit 1
fi

systemctl enable docker

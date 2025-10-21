#! /bin/bash

# exit on failure
set -e


# ensure superuser privileges
if [[ $EUID -ne 0 ]]; then
  echo "Run as root: sudo $0"
  exit 1
fi


echo installing stuff...
apt install -y fail2ban


echo Backup sshd config...
cp /etc/ssh/sshd_config /etc/ssh/sshd_config.bak.$(date +%F_%T)


echo Disable password login and enable key-based login...
sed -i 's/^#\?PasswordAuthentication.*/PasswordAuthentication no/' /etc/ssh/sshd_config
sed -i 's/^#\?ChallengeResponseAuthentication.*/ChallengeResponseAuthentication no/' /etc/ssh/sshd_config
sed -i 's/^#\?UsePAM.*/UsePAM no/' /etc/ssh/sshd_config
sed -i 's/^#\?PubkeyAuthentication.*/PubkeyAuthentication yes/' /etc/ssh/sshd_config


echo Restart ssh service...
systemctl restart ssh


#!/usr/bin/env bash
set -euo pipefail

sleep 30

# Update and upgrade packages
sudo apt update -y
sudo apt upgrade -y
sudo apt install -y python3 python3-pip

# Install and start open vpn
# sudo apt install -y openvpn easy-rsa
# sudo systemctl enable openvpn
# sudo systemctl start openvpn

# Extract your tar archive
cd ~/
tar -xf webclient.tar


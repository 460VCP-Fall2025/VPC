#!/usr/bin/env bash
set -euo pipefail

sleep 30

# Update and upgrade packages
sudo apt update -y
sudo apt upgrade -y
sudo apt install -y python3 python3-pip

# Extract your tar archive
cd ~/
tar -xf webclient.tar


#!/usr/bin/env bash
set -euo pipefail

sleep 30

# Update and upgrade packages
sudo apt update -y
sudo apt upgrade -y
sudo apt install -y python3 python3-pip

# Extract your tar archive
cd ~/
tar -xf webserver.tar
rm webserver.tar


sudo mv /tmp/webserver.service /etc/systemd/system/webserver.service
sudo chmod 644 /etc/systemd/system/webserver.service

sudo mkdir -p /var/lib/cloud/scripts/per-boot


sudo systemctl daemon-reload
sudo tee /var/lib/cloud/scripts/per-boot/start-webserver.sh >/dev/null <<'EOF'
> #!/bin/bash
# start webserver.service automatically after every boot
systemctl start webserver.service
EOF
sudo chmod +x /var/lib/cloud/scripts/per-boot/start-webserver.sh

sudo systemctl enable webserver.service
sudo systemctl start webserver.service




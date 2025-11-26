#!/usr/bin/env bash
set -euo pipefail

sleep 30

# Update and upgrade packages
sudo apt update -y
sudo apt upgrade -y
sudo apt install -y python3 python3-pip

# Extract webclient archive
cd ~/
tar -xf webclient.tar
rm webclient.tar

# Create directory structure
mkdir -p ~/openvpn-config
mkdir -p ~/webclient
mkdir -p ~/ssh_commands

# Move files to correct locations
mv ~/webclient.py ~/webclient/
mv ~/install_openvpn.sh ~/openvpn-config/
mv ~/run_install_openvpn_script.sh ~/openvpn-config/


#Create ssh files and set perms and ownership
touch /home/ubuntu/ssh_commands/ssh_blue.sh /home/ubuntu/ssh_commands/ssh_green.sh /home/ubuntu/ssh_commands/ssh_nat.sh
chmod +x /home/ubuntu/ssh_commands/ssh_blue.sh
chmod +x /home/ubuntu/ssh_commands/ssh_green.sh
chmod +x /home/ubuntu/ssh_commands/ssh_nat.sh
chown ubuntu:ubuntu /home/ubuntu/ssh_commands/ssh_blue.sh
chown ubuntu:ubuntu /home/ubuntu/ssh_commands/ssh_green.sh
chown ubuntu:ubuntu /home/ubuntu/ssh_commands/ssh_nat.sh

# Make scripts executable
chmod +x ~/openvpn-config/install_openvpn.sh
chmod +x ~/openvpn-config/run_install_openvpn_script.sh

# Install the service file (it's in /tmp from Packer provisioner)
sudo mv /tmp/run_install_openvpn_script.service /etc/systemd/system/
sudo chmod 644 /etc/systemd/system/run_install_openvpn_script.service

# Enable the service
sudo systemctl daemon-reload
sudo systemctl enable run_install_openvpn_script.service

#Log message
if [ $? -eq 0 ]; then
    echo "SUCCESS: VPN AMI setup completed successfully at $(date)" | sudo tee -a /var/log/vpn-packer-setup.log
    echo "VPN AMI setup completed successfully!"
else
    echo "FAILURE: VPN AMI setup failed at $(date)" | sudo tee -a /var/log/vpn-packer-setup.log
    echo "VPN AMI setup failed!"
    exit 1
fi


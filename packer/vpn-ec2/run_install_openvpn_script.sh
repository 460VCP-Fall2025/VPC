#!/bin/bash

# Set working directory
cd /home/ubuntu/openvpn-config/

# Make install script executable and run it
chmod +x install_openvpn.sh
sudo ./install_openvpn.sh

# Wait for VPN key file to be created
while [ ! -f /home/ubuntu/vpn-key.ovpn ]; do 
    sleep 1
done

# Move the key to openvpn config directory
mv ~/vpn-key.ovpn ~/openvpn-config/

# Log completion
echo "VPN setup completed at $(date)" >> /var/log/vpn-setup.log





#!/bin/bash      
sleep 30

sudo apt update -y,
sudo apt install -y iptables ufw net-tools,

echo 1 | sudo tee /proc/sys/net/ipv4/ip_forward,
sudo sed -i 's/#net.ipv4.ip_forward=1/net.ipv4.ip_forward=1/' /etc/sysctl.conf,
sudo sysctl -p,


sudo iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE,
sudo iptables -A FORWARD -i eth0 -o eth0 -m state --state RELATED,ESTABLISHED -j ACCEPT,
sudo iptables -A FORWARD -i eth0 -o eth0 -j ACCEPT,


echo '#!/bin/bash' | sudo tee /etc/rc.local,
echo 'iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE' | sudo tee -a /etc/rc.local,
echo 'exit 0' | sudo tee -a /etc/rc.local,
sudo chmod +x /etc/rc.local,
sudo systemctl daemon-reload
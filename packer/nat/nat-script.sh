 "sudo apt-get update -y",
     "sudo apt-get install -y iptables-persistent net-tools",
      "sudo sysctl -w net.ipv4.ip_forward=1",
      "echo 'net.ipv4.ip_forward=1' | sudo tee -a /etc/sysctl.conf",
      "sudo iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE",
      "sudo iptables-save | sudo tee /etc/iptables/rules.v4",
      "sudo systemctl enable netfilter-persistent",
      "echo'NAT On'"
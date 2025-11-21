packer {
  required_plugins {
    amazon = {
      source  = "github.com/hashicorp/amazon"
      version = ">= 1.2.0"
    }
  }
}

variable "aws_region" {
  default = "us-east-1"
}

variable "vpc_id" {
  type    = string
  default = null
}

variable "subnet_id" {
  type    = string
  default = null
}

source "amazon-ebs" "nat" {
  region        = var.aws_region
  instance_type = "t3.micro"
  ami_name      = "custom-nat-ami-{{timestamp}}"
  ssh_username  = "ubuntu"

  source_ami_filter {
    filters = {
      name                = "ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"
      virtualization-type = "hvm"
    }
    owners      = ["099720109477"]
    most_recent = true
  }

  vpc_id    = var.vpc_id
  subnet_id = var.subnet_id
}

build {
  name    = "nat-build"
  sources = ["source.amazon-ebs.nat"]

  provisioner "shell" {
    inline = [
      "sudo apt update -y",
      "sudo apt install -y iptables ufw net-tools",

      # Enable IP forwarding
      "echo 1 | sudo tee /proc/sys/net/ipv4/ip_forward",
      "sudo sed -i 's/#net.ipv4.ip_forward=1/net.ipv4.ip_forward=1/' /etc/sysctl.conf",
      "sudo sysctl -p",

      # Set NAT rules
      "sudo iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE",
      "sudo iptables -A FORWARD -i eth0 -o eth0 -m state --state RELATED,ESTABLISHED -j ACCEPT",
      "sudo iptables -A FORWARD -i eth0 -o eth0 -j ACCEPT",

      # Enable rc.local support (for persistence)
      "echo '#!/bin/bash' | sudo tee /etc/rc.local",
      "echo 'iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE' | sudo tee -a /etc/rc.local",
      "echo 'exit 0' | sudo tee -a /etc/rc.local",
      "sudo chmod +x /etc/rc.local",
      "sudo systemctl daemon-reload"
    ]
  }


}


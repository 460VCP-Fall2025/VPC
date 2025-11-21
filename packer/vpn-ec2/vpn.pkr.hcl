packer {
  required_plugins {
    amazon = {
      version = ">= 1.2.0"
      source  = "github.com/hashicorp/amazon"
    }
  }
}


# -----------------------------
# Get latest Ubuntu AMI
# -----------------------------
data "amazon-ami" "ubuntu" {
  filters = {
    name                = "ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"
    virtualization-type = "hvm"
  }

  owners      = ["099720109477"] # Canonical
  most_recent = true
  region      = "us-east-1"
}

locals {
  timestamp = regex_replace(timestamp(), "[- TZ:]", "")
}
# -----------------------------
# AMI Build Definition
# -----------------------------
source "amazon-ebs" "vpn-ec2" {
  ami_name      = "vpn-ami-${local.timestamp}"
  source_ami    = "${data.amazon-ami.ubuntu.id}"
  instance_type = "t3.micro"
  region        = "us-east-1"
  ssh_username  = "ubuntu"
}

build {
  sources = ["source.amazon-ebs.vpn-ec2"]

  # Copy your webclient archive
  provisioner "file" {
    source      = "./webclient.tar"
    destination = "/home/ubuntu/webclient.tar"
  }

  provisioner "file" {
    source      = "./install_openvpn.sh"
    destination = "/home/ubuntu/install_openvpn.sh"
  }

  provisioner "file" {
    source      = "./run_install_openvpn_script.sh"
    destination = "/home/ubuntu/run_install_openvpn_script.sh"
  }

  provisioner "file" {
    source      = "./run_install_openvpn_script.service"
    destination = "/tmp/run_install_openvpn_script.service"
  }

  provisioner "file" {
    source      = "./send_request.sh"
    destination = "/home/ubuntu/send_request.sh"
  }

  # Run setup script
  provisioner "shell" {
    script = "./vpn_packer.sh"
  }
}



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
source "amazon-ebs" "private-server" {
  ami_name      = "private-server-ami-${local.timestamp}"
  source_ami    = "${data.amazon-ami.ubuntu.id}"
  instance_type = "t3.micro"
  region        = "us-east-1"
  ssh_username  = "ubuntu"
}

build {
  sources = ["source.amazon-ebs.private-server"]

  # Copy your webserver archive
  provisioner "file" {
    source      = "./webserver.tar"
    destination = "/home/ubuntu/webserver.tar"
  }

  # Copy your systemd service definition
  provisioner "file" {
    source      = "./webserver.service"
    destination = "/tmp/webserver.service"
  }

  # Run setup script
  provisioner "shell" {
    script = "./private_server_packer.sh"
  }
}



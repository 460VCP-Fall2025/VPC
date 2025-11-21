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
  ami_name      = "nat-ami-{{timestamp}}"
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
    script = "./nat-script.sh"
  }
}


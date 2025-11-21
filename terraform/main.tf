provider "aws" {
  region = "us-east-1"
}

# -----------------------------
# VPC
# -----------------------------
resource "aws_vpc" "main" {
  cidr_block           = "10.0.0.0/24" // 256 hosts, 128 hosts per subnet
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = "460VPC"
  }
}

# -----------------------------
# Public Subnet (10.0.0.0/25)
# -----------------------------
resource "aws_subnet" "public" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.0.0/25"
  map_public_ip_on_launch = true
  availability_zone       = "us-east-1a"

  tags = {
    Name = "460VPC-subnet-public1-us-east-1a"
  }
}

# -----------------------------
# Private Subnet Blue (10.0.0.128/26)
# -----------------------------
resource "aws_subnet" "private_blue" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.0.128/26"
  availability_zone = "us-east-1b"

  tags = {
    Name = "460VPC-subnet-privateblue-us-east-1b"
  }
}

# -----------------------------
# Private Subnet Gree (10.0.0.192/26)
# -----------------------------
resource "aws_subnet" "private_green" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.0.192/26"
  availability_zone = "us-east-1c"

  tags = {
    Name = "460VPC-subnet-privategreen-us-east-1c"
  }
}



# -----------------------------
# Get latest Ubuntu AMI
# -----------------------------
data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["099720109477"] # Canonical
}






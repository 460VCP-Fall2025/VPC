terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
  required_version = ">= 1.3.0"
}

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
# Private Subnet (10.0.0.128/25)
# -----------------------------
resource "aws_subnet" "private" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.0.128/25"
  availability_zone = "us-east-1b"

  tags = {
    Name = "460VPC-subnet-private1-us-east-1b"
  }
}

# -----------------------------
# Internet Gateway (for Public)
# -----------------------------
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "460VPC-igw"
  }
}

# -----------------------------
# Route Tables
# -----------------------------
# Public route table
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = {
    Name = "460VPC-rtb-public"
  }
}

# Private route table (local-only)
resource "aws_route_table" "private" {
  vpc_id = aws_vpc.main.id

  # AWS automatically provides a local route,
  # so we don't add any routes manually yet

  tags = {
    Name = "460VPC-rtb-private1-us-east-1b"
  }
}

# -----------------------------
# Route Table Associations
# -----------------------------
resource "aws_route_table_association" "public_assoc" {
  subnet_id      = aws_subnet.public.id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table_association" "private_assoc" {
  subnet_id      = aws_subnet.private.id
  route_table_id = aws_route_table.private.id
}



/*
# -----------------------------
# Example Public EC2
# -----------------------------
resource "aws_instance" "public_ec2" {
  ami                         = "ami-0e6a50b0059fd2cc3" # Ubuntu 24.04 LTS
  instance_type               = "t3.micro"
  subnet_id                   = aws_subnet.public.id
  associate_public_ip_address  = true

  tags = {
    Name = "PublicInstance"
  }
}
*/

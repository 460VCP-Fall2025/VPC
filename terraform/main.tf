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



# -----------------------------
# Security Groups
# -----------------------------
# Public SG: allow SSH from anywhere and allow all outbound
resource "aws_security_group" "public_sg" {
  name        = "460VPC-public-sg"
  description = "Allow SSH inbound from anywhere for public instances"
  vpc_id      = aws_vpc.main.id

  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "460VPC-public-sg"
  }
}

# Private SG: allow SSH only from the public SG and allow all outbound
resource "aws_security_group" "private_sg" {
  name        = "460VPC-private-sg"
  description = "Allow SSH from public instances and internal traffic"
  vpc_id      = aws_vpc.main.id

  ingress {
    description      = "SSH from public instances"
    from_port        = 22
    to_port          = 22
    protocol         = "tcp"
    security_groups  = [aws_security_group.public_sg.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "460VPC-private-sg"
  }
}

# -----------------------------
# EC2 Instances
# -----------------------------
# Two public t2.micro instances
resource "aws_instance" "public" {
  count                     = 2
  ami                       = data.aws_ami.ubuntu.id
  instance_type             = "t3.micro"
  subnet_id                 = aws_subnet.public.id
  associate_public_ip_address = true
  vpc_security_group_ids    = [aws_security_group.public_sg.id]

  tags = {
    Name = "PublicInstance-${count.index + 1}"
  }
}

# One private t2.micro instance
resource "aws_instance" "private" {
  ami                    = data.aws_ami.ubuntu.id
  instance_type          = "t3.micro"
  subnet_id              = aws_subnet.private.id
  associate_public_ip_address = false
  vpc_security_group_ids = [aws_security_group.private_sg.id]

  tags = {
    Name = "PrivateInstance-1"
  }
}


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


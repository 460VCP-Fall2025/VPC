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

  tags = {
    Name = "460VPC-rtb-private"
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


# VPN SG
resource "aws_security_group" "vpn_sg" {
  name        = "460VPC-vpn-sg"
  description = "Allow SSH, HTTPS, and ICMP inbound for VPN instance"
  vpc_id      = aws_vpc.main.id

  # OpenVPN UDP port
  ingress {
    from_port   = 1194
    to_port     = 1194
    protocol    = "udp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "SSH (TCP 22)"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "HTTPS (TCP 443)"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "ICMP (ping)"
    from_port   = -1
    to_port     = -1
    protocol    = "icmp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "460VPC-vpn-sg"
  }
}

# NAT SG: allow communication only between VPN-EC2 and private subnet
resource "aws_security_group" "nat_sg" {
  name        = "460VPC-nat-sg"
  description = "Allow communication only between VPN-EC2 and private subnet"
  vpc_id      = aws_vpc.main.id

  # Inbound: accept from VPN-EC2 and private subnet only
  ingress {
    description     = "All traffic from VPN-EC2"
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
    security_groups = [aws_security_group.vpn_sg.id]
  }

  ingress {
    description = "All traffic from private subnet"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = [aws_subnet.private.cidr_block]
  }

  # Outbound: send only to VPN-EC2 and private subnet
  egress {
    description     = "All traffic to VPN-EC2"
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
    security_groups = [aws_security_group.vpn_sg.id]
  }

  egress {
    description = "All traffic to private subnet"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = [aws_subnet.private.cidr_block]
  }

  tags = {
    Name = "460VPC-nat-sg"
  }
}
 
# -----------------------------
# Private SG: allow only NAT-EC2 communication
# -----------------------------
resource "aws_security_group" "private_sg" {
  name        = "460VPC-private-sg"
  description = "Allow traffic only between NAT-EC2 and private instance"
  vpc_id      = aws_vpc.main.id

# --- Inbound Rules ---

  # Allow VPN-EC2 to access private server on TCP/8080
  ingress {
    description     = "VPN-EC2 to private-server on port 8080"
    from_port       = 8080
    to_port         = 8080
    protocol        = "tcp"
    security_groups = [aws_security_group.vpn_sg.id]
  }

  # ping testing if vpn works
  ingress {
    description = "ICMP (ping)"
    from_port   = -1
    to_port     = -1
    protocol    = "icmp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Allow NAT-EC2 if you still use it for SSH, mgmt, etc.
  ingress {
    description     = "NAT-EC2 internal management access (optional)"
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
    security_groups = [aws_security_group.nat_sg.id]
  }

  # --- Outbound Rules ---

  # Allow all outbound to NAT-EC2 (for Internet access)
  egress {
    description     = "Private to NAT (for Internet)"
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
    security_groups = [aws_security_group.nat_sg.id]
  }

  # Allow all outbound to VPN-EC2 (for responses or diagnostics)
  egress {
    description     = "Private to VPN (all ports)"
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
    security_groups = [aws_security_group.vpn_sg.id]
  }

  tags = {
    Name = "460VPC-private-sg"
  }
}

# -----------------------------
# EC2 Instances
# -----------------------------
# Two public t3.micro instances

# VPN EC2
resource "aws_instance" "vpn_ec2" {
  ami                         = data.aws_ami.vpn_ami.id
  instance_type               = "t3.micro"
  subnet_id                   = aws_subnet.public.id
  associate_public_ip_address = true
  key_name                    = aws_key_pair.vpn_keypair.key_name
  vpc_security_group_ids      = [aws_security_group.vpn_sg.id]

  tags = {
    Name = "VPN-EC2"
  }

  # script needs to be ran after the ec2 starts
  provisioner "remote-exec"{
    connection {
      type = "ssh"
      user = "ubuntu"
      private_key = tls_private_key.vpn_key.private_key_pem
      host = self.public_ip
    }
    inline = [
      "chmod +x install_openvpn.sh",
      "sudo ./install_openvpn.sh",
      "while [ ! -f /home/ubuntu/vpn-key.ovpn ]; do sleep 1; done"
      ]
  }
}


#output ssh command for VPN-EC2 upon creation
output "vpn_ec2_ssh_command" {
  description = "SSH command for VPN-EC2"
  value       = "ssh -i vpn-keypair.pem ubuntu@${aws_instance.vpn_ec2.public_ip}"
}
output "vpn_ec2_ovpn_command" {
  description = "Run this command to get the .ovpn key"
  value       = "scp -o StrictHostKeyChecking=no -i ./vpn-keypair.pem ubuntu@${aws_instance.vpn_ec2.public_ip}:/home/ubuntu/vpn-key.ovpn ${path.module}/vpn-key.ovpn"
}

# NAT EC2
resource "aws_instance" "nat_ec2" {
  ami                         = data.aws_ami.ubuntu.id
  instance_type               = "t3.micro"
  subnet_id                   = aws_subnet.public.id
  associate_public_ip_address = true
  vpc_security_group_ids      = [aws_security_group.nat_sg.id]

  tags = {
    Name = "NAT-EC2"
  }
}

# One private t2.micro instance
resource "aws_instance" "private" {
  ami                         = data.aws_ami.private_server_ami.id
  instance_type               = "t3.micro"
  subnet_id                   = aws_subnet.private.id
  associate_public_ip_address = false
  vpc_security_group_ids      = [aws_security_group.private_sg.id]
  
  tags = {
    Name = "PrivateInstance-1"
  }
}

# -----------------------------
# Generate public/private key for the VPN-EC2 instance
# -----------------------------

# Generate a new RSA private key for VPN-EC2
resource "tls_private_key" "vpn_key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

# Upload the public key to AWS as a Key Pair
resource "aws_key_pair" "vpn_keypair" {
  key_name   = "vpn-keypair"
  public_key = tls_private_key.vpn_key.public_key_openssh
}

# Write the private key (.pem) file locally
resource "local_file" "vpn_private_key" {
  content              = tls_private_key.vpn_key.private_key_pem
  filename             = "${path.module}/vpn-keypair.pem"
  file_permission      = "0400"
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


# -----------------------------
# Get latest Ubuntu AMI
# -----------------------------
data "aws_ami" "private_server_ami" {
  most_recent = true
  name_regex = "private-server-ami-*"
  owners = ["self"]
}

# -----------------------------
# Get latest Ubuntu AMI
# -----------------------------
data "aws_ami" "vpn_ami" {
  most_recent = true
  name_regex = "private-vpn-ami-*"
  owners = ["self"]
}


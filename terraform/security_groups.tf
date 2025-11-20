#------------------------------
# SG for VPN EC2: SSH inbound, only ALB outbound
#------------------------------
resource "aws_security_group" "vpn_sg" {
  name   = "460VPC-vpn-sg"
  vpc_id = aws_vpc.main.id

  # SSH
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # VPN -> private subnets on port 8080
  # (NLB sits inside private subnets)
  egress {
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["10.0.0.0/24"] # your full VPC range
  }
}


resource "aws_security_group" "nat_sg" {
  name   = "460VPC-nat-sg"
  vpc_id = aws_vpc.main.id

  # NAT -> private subnets on port 8080
  egress {
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["10.0.0.0/24"]
  }

  # private subnets -> NAT
  ingress {
    from_port   = 0
    to_port     = 65535
    protocol    = "tcp"
    cidr_blocks = ["10.0.0.0/24"]
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
    cidr_blocks = ["10.0.0.0/24"]  # your VPC CIDR
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



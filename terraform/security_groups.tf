#------------------------------
# SG for VPN EC2
#------------------------------
resource "aws_security_group" "vpn_sg" {
  name   = "460VPC-vpn-sg"
  vpc_id = aws_vpc.main.id

  # SSH access
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # Restrict to your IP in production
    description = "SSH access"
  }

  ingress {
    description = "OpenVPN UDP"
    from_port   = 1194
    to_port     = 1194
    protocol    = "udp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Allow all outbound traffic
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    description = "All outbound traffic"
  }

  tags = {
    Name = "vpn-ec2-sg"
  }
}
resource "aws_security_group" "private_sg" {
  name        = "460VPC-private-sg"
  description = "Allow App traffic from VPC, SSH from VPN-EC2"
  vpc_id      = aws_vpc.main.id

  # 1. Allow TCP 8080 from anywhere in the VPC
  ingress {
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = [aws_vpc.main.cidr_block] // 10.0.0.0/16
    description = "Allow App Port from entire VPC"
  }

  # 2. MANAGEMENT (SSH and Ping)
  ingress {
    from_port       = 22
    to_port         = 22
    protocol        = "tcp"
    security_groups = [aws_security_group.vpn_sg.id]
    description     = "SSH from VPN-EC2"
  }

  ingress {
    description     = "ICMP (ping) from VPN-EC2"
    from_port       = -1
    to_port         = -1
    protocol        = "icmp"
    security_groups = [aws_security_group.vpn_sg.id]
  }

  # 3. EGRESS (Outbound traffic for internet access via NAT)
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    description = "All outbound traffic"
  }

  tags = {
    Name = "460VPC-private-sg"
  }
}



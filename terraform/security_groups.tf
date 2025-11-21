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



#------------------------------
# SG for NAT EC2
#------------------------------
resource "aws_security_group" "nat_sg" {
  name_prefix = "nat-instance-"
  vpc_id      = aws_vpc.main.id

  # INGRESS: Allow traffic FROM private subnets
  ingress {
    from_port = 80
    to_port   = 80
    protocol  = "tcp"
    cidr_blocks = [
      aws_subnet.private_blue.cidr_block,
      aws_subnet.private_green.cidr_block
    ]
    description = "HTTP from private subnets"
  }

  ingress {
    from_port = 443
    to_port   = 443
    protocol  = "tcp"
    cidr_blocks = [
      aws_subnet.private_blue.cidr_block,
      aws_subnet.private_green.cidr_block
    ]
    description = "HTTPS from private subnets"
  }

  # Allow all TCP traffic from private subnets (more permissive)
  ingress {
    from_port = 0
    to_port   = 65535
    protocol  = "tcp"
    cidr_blocks = [
      aws_subnet.private_blue.cidr_block,
      aws_subnet.private_green.cidr_block
    ]
    description = "All TCP from private subnets"
  }

  # SSH access for management
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["${aws_instance.vpn_ec2.private_ip}/32"] # Only VPN-EC2 can ssh into NAT-EC2
    description = "SSH management access"
  }

  # EGRESS: Allow traffic TO internet (for forwarding)
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    description = "All traffic to internet"
  }

  # EGRESS: Allow return traffic TO private subnets
  egress {
    from_port = 32768
    to_port   = 65535
    protocol  = "tcp"
    cidr_blocks = [
      aws_subnet.private_blue.cidr_block,
      aws_subnet.private_green.cidr_block
    ]
    description = "Return traffic to private subnets (ephemeral ports)"
  }

  # EGRESS: Allow specific return traffic to private subnets
  egress {
    from_port = 80
    to_port   = 80
    protocol  = "tcp"
    cidr_blocks = [
      aws_subnet.private_blue.cidr_block,
      aws_subnet.private_green.cidr_block
    ]
    description = "HTTP return traffic to private subnets"
  }

  egress {
    from_port = 443
    to_port   = 443
    protocol  = "tcp"
    cidr_blocks = [
      aws_subnet.private_blue.cidr_block,
      aws_subnet.private_green.cidr_block
    ]
    description = "HTTPS return traffic to private subnets"
  }

  tags = {
    Name = "nat-sg"
  }
}


#------------------------------
# SG for private instances (blue/green instances)
#------------------------------
resource "aws_security_group" "private_sg" {
  name        = "460VPC-private-sg"
  description = "Allow traffic to/from NAT on any, and from VPN-EC2 on port 8080"
  vpc_id      = aws_vpc.main.id

  # App port from public subnet
  ingress {
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["${aws_instance.vpn_ec2.private_ip}/32"]
  }

  # App port from NLB subnets (for health checks)
  ingress {
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = [
      aws_subnet.private_blue.cidr_block,
      aws_subnet.private_green.cidr_block
    ]
  }

  # SSH from VPN EC2 (for management)
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["${aws_instance.vpn_ec2.private_ip}/32"]
  }

  # ping testing if vpn works
  ingress {
    description = "ICMP (ping)"
    from_port   = -1
    to_port     = -1
    protocol    = "icmp"
    cidr_blocks = ["${aws_instance.vpn_ec2.private_ip}/32"]
  }

  # Outbound HTTP/HTTPS to NAT instance for internet access
  egress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["${aws_instance.nat_ec2.private_ip}/32"]
  }

  egress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["${aws_instance.nat_ec2.private_ip}/32"]
  }

  # Allow all outbound to NAT instance
  egress {
    from_port   = 0
    to_port     = 65535
    protocol    = "tcp"
    cidr_blocks = ["${aws_instance.nat_ec2.private_ip}/32"]
  }

  # Return traffic to public subnet
  egress {
    from_port   = 32768
    to_port     = 65535
    protocol    = "tcp"
    cidr_blocks = [aws_subnet.public.cidr_block]
  }

  tags = {
    Name = "460VPC-private-sg"
  }
}



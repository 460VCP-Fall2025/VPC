#This resource forces a change (replacement) when blue/green environment variables change.
# It is used as a dependency trigger to ensure the Load Balancer Listener or Target Group weights 
# are re-evaluated and traffic is reliably shifted during a deployment.
resource "terraform_data" "trigger_replacement" {
  input = jsonencode({
    blue  = var.enable_blue_env
    green = var.enable_green_env
  })
}



# -----------------------------
# EC2 Instances
# -----------------------------
# Two public t3.micro instances

# VPN EC2
resource "aws_instance" "vpn_ec2" {

  depends_on = [
    local_file.unix_send_request_script
  ]


  ami                         = data.aws_ami.vpn_ami.id
  instance_type               = "t3.micro"
  subnet_id                   = aws_subnet.public.id
  associate_public_ip_address = true
  key_name                    = aws_key_pair.vpn_keypair.key_name
  vpc_security_group_ids      = [aws_security_group.vpn_sg.id]

  tags = {
    Name = "VPN-EC2"
  }
}


# Blue EC2 Instance (only created when blue is active)
resource "aws_instance" "blue" {
  count                  = var.enable_blue_env ? 1 : 0 //
  ami                    = data.aws_ami.private_server_ami.id
  instance_type          = "t3.micro"
  subnet_id              = aws_subnet.private_blue.id
  vpc_security_group_ids = [aws_security_group.private_sg.id]
  key_name               = aws_key_pair.vpn_keypair.key_name


  tags = {
    Name = "Blue-Instance"
  }

  user_data = <<-EOF
  #!/bin/bash

  mkdir -p /home/ubuntu/webserver # Ensure directory exists
  # Metadata
  INSTANCE_ID=$(curl -s http://169.254.169.254/latest/meta-data/instance-id)
  AZ=$(curl -s http://169.254.169.254/latest/meta-data/placement/availability-zone)

  # Replace placeholders
  sed -i "s/__ENV__/BLUE/" /home/ubuntu/webserver/response.html
  sed -i "s/__INSTANCE_ID__/$INSTANCE_ID/" /home/ubuntu/webserver/response.html
  sed -i "s/__AZ__/$AZ/" /home/ubuntu/webserver/response.html
EOF
}

# One private green EC2 Instance
resource "aws_instance" "green" {
  count                       = var.enable_green_env ? 1 : 0
  ami                         = data.aws_ami.private_server_ami.id
  instance_type               = "t3.micro"
  subnet_id                   = aws_subnet.private_green.id
  associate_public_ip_address = false
  vpc_security_group_ids      = [aws_security_group.private_sg.id]
  key_name                    = aws_key_pair.vpn_keypair.key_name

  tags = {
    Name = "Green-Instance"
  }

  user_data = <<-EOF
  #!/bin/bash

  mkdir -p /home/ubuntu/webserver # Ensure directory exists
  # Metadata
  INSTANCE_ID=$(curl -s http://169.254.169.254/latest/meta-data/instance-id)
  AZ=$(curl -s http://169.254.169.254/latest/meta-data/placement/availability-zone)

  # Replace placeholders
  sed -i "s/__ENV__/GREEN/" /home/ubuntu/webserver/response.html
  sed -i "s/__INSTANCE_ID__/$INSTANCE_ID/" /home/ubuntu/webserver/response.html
  sed -i "s/__AZ__/$AZ/" /home/ubuntu/webserver/response.html
EOF
}



















//Making the send_request.sh script locally
resource "local_file" "send_request_script" {
  filename = "../webclient/send_request.sh"

  content = <<-EOF
    #!/usr/bin/env bash
    python3 /home/ubuntu/webclient/webclient.py ${aws_lb.nlb.dns_name} 8080 response.html
  EOF
}


# -----------------------------
# EC2 Instances
# -----------------------------
# Two public t3.micro instances

# VPN EC2
resource "aws_instance" "vpn_ec2" {

  depends_on = [
    local_file.send_request_script // creating send_request.sh first 
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
  provisioner "file" {
    connection {
      type        = "ssh"
      host        = self.public_ip
      user        = "ubuntu"
      private_key = tls_private_key.vpn_key.private_key_pem
    }

    source      = local_file.vpn_private_key.filename
    destination = "/home/ubuntu/.ssh/id_rsa"
  }

  provisioner "file" {
    source      = local_file.send_request_script.filename
    destination = "/home/ubuntu/send_request.sh"

    connection {
      type        = "ssh"
      user        = "ubuntu"
      host        = self.public_ip
      private_key = tls_private_key.vpn_key.private_key_pem
    }
  }

  #Installing vpn software and setting up the webclient.py run script
  provisioner "remote-exec" {
    connection {
      type        = "ssh"
      user        = "ubuntu"
      private_key = tls_private_key.vpn_key.private_key_pem
      host        = self.public_ip
    }

    inline = [
      "chmod 700 /home/ubuntu/.ssh",
      "chmod 600 /home/ubuntu/.ssh/id_rsa",

      # BLUE instance check
      <<EOF
      BLUE_IP="${try(aws_instance.blue[0].private_ip, "")}"
      if [ -z "$BLUE_IP" ]; then
        echo "BLUE instance is not running" > /home/ubuntu/ssh_commands/ssh_blue.sh
      else
        echo "ssh ubuntu@$BLUE_IP" > /home/ubuntu/ssh_commands/ssh_blue.sh
      fi
      EOF
      ,

      # GREEN instance check
      <<EOF
      GREEN_IP="${try(aws_instance.green[0].private_ip, "")}"
      if [ -z "$GREEN_IP" ]; then
        echo "GREEN instance is not running" > /home/ubuntu/ssh_commands/ssh_green.sh
      else
        echo "ssh ubuntu@$GREEN_IP" > /home/ubuntu/ssh_commands/ssh_green.sh
      fi
      EOF
      ,

      # NAT always exists
      "echo 'ssh ubuntu@${aws_instance.nat_ec2.private_ip}' > /home/ubuntu/ssh_commands/ssh_nat.sh"
    ]


  }
}


# NAT EC2
resource "aws_instance" "nat_ec2" {
  ami                         = data.aws_ami.nat_ami.id
  instance_type               = "t3.micro"
  subnet_id                   = aws_subnet.public.id
  associate_public_ip_address = true
  vpc_security_group_ids      = [aws_security_group.nat_sg.id]
  source_dest_check           = false                             # CRITICAL: Must disable for NAT functionality
  key_name                    = aws_key_pair.vpn_keypair.key_name // to ssh into Nat-EC2 from VPN-EC2


  tags = {
    Name = "NAT-EC2"
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

















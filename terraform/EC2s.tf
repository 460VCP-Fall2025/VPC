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

# One private blue EC2 Instance
resource "aws_instance" "blue" {
  ami                         = data.aws_ami.private_server_ami.id
  instance_type               = "t3.micro"
  subnet_id                   = aws_subnet.private_a.id
  associate_public_ip_address = false
  vpc_security_group_ids      = [aws_security_group.private_sg.id]

  tags = {
    Name = "BlueInstance"
  }
}

# One private green EC2 Instance
resource "aws_instance" "green" {
  ami                         = data.aws_ami.private_server_ami.id
  instance_type               = "t3.micro"
  subnet_id                   = aws_subnet.private_b.id
  associate_public_ip_address = false
  vpc_security_group_ids      = [aws_security_group.private_sg.id]

  tags = {
    Name = "GreenInstance"
  }
}
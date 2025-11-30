# -----------------------------
# Provisioning Logic of the VPN-EC2.
# Runs whenever blue or green get switched
# -----------------------------
resource "null_resource" "vpn_ec2_provisioning" {
  # This triggers recreation of the null_resource (and thus re-running provisioners)
  # whenever terraform_data.trigger_replacement plans a change.
  triggers = {
    reprovision_trigger = terraform_data.trigger_replacement.output
  }
  
  # Ensure the null_resource runs *after* the main EC2 instance is available
  depends_on = [
    aws_instance.vpn_ec2,
    local_file.unix_send_request_script
  ]
  
  provisioner "file" {
    connection {
      type        = "ssh"
      host        = aws_instance.vpn_ec2.public_ip
      user        = "ubuntu"
      private_key = tls_private_key.vpn_key.private_key_pem
    }
    source      = local_file.vpn_private_key.filename
    destination = "/home/ubuntu/.ssh/id_rsa"
  }

  provisioner "file" {
    source      = local_file.unix_send_request_script.filename
    destination = "/home/ubuntu/send_request.sh"

    connection {
      type        = "ssh"
      user        = "ubuntu"
      host        = aws_instance.vpn_ec2.public_ip
      private_key = tls_private_key.vpn_key.private_key_pem
    }
  }

# Installing vpn software and setting up the webclient.py run script
  provisioner "remote-exec" {
    connection {
      type        = "ssh"
      user        = "ubuntu"
      private_key = tls_private_key.vpn_key.private_key_pem
      host        = aws_instance.vpn_ec2.public_ip
    }

    inline = [
      "chmod 700 /home/ubuntu/.ssh",
      "chmod 600 /home/ubuntu/.ssh/id_rsa",
      "chmod +x /home/ubuntu/send_request.sh",

      # BLUE instance check - WRAPPED TO REMOVE \r (CRLF)
      # The outer quotes ensure the entire block is treated as a single command string
      "(",
      <<EOT
      BLUE_IP="${try(aws_instance.blue[0].private_ip, "")}"
      if [ -z "$BLUE_IP" ]; then
        echo "BLUE instance is not running" > /home/ubuntu/commands_ssh/blue_ssh.sh
      else
        echo "ssh ubuntu@$BLUE_IP" > /home/ubuntu/commands_ssh/blue_ssh.sh
      fi
EOT
      ," ) | tr -d '\r' | sh",
      

      # GREEN instance check - WRAPPED TO REMOVE \r (CRLF)
      "(",
      <<EOT
      GREEN_IP="${try(aws_instance.green[0].private_ip, "")}"
      if [ -z "$GREEN_IP" ]; then
        echo "GREEN instance is not running" > /home/ubuntu/commands_ssh/green_ssh.sh
      else
        echo "ssh ubuntu@$GREEN_IP" > /home/ubuntu/commands_ssh/green_ssh.sh
      fi
EOT
      ," ) | tr -d '\r' | sh",
    ]
  }
}

//Making the send_request.sh script locally
resource "local_file" "unix_send_request_script" {
  filename = "../webclient/unix_send_request.sh"

  content = <<-EOF
    #!/usr/bin/env bash
    python3 webclient.py ${aws_lb.nlb.dns_name} 8080 response.html
  EOF
}

//Making the send_request.sh script locally
resource "local_file" "win_send_request_script" {
  filename = "../webclient/win_send_request.sh"

  content = <<-EOF
    #!/usr/bin/env bash
    python webclient.py ${aws_lb.nlb.dns_name} 8080 response.html
  EOF
}


//Securely copies the vpn-key.opvn file from the vpn-ec2 upon its creation
resource "null_resource" "scp_vpn_config" {
  depends_on = [aws_instance.vpn_ec2,]

  triggers = {
    public_ip = aws_instance.vpn_ec2.public_ip
  }

provisioner "local-exec" {
  command = <<-EOT
    echo "Waiting 30 seconds for SSH service to start..."
    sleep 30
    scp -o StrictHostKeyChecking=no -i ./vpn-keypair.pem ubuntu@${aws_instance.vpn_ec2.public_ip}:/home/ubuntu/openvpn-config/vpn-key.ovpn ${path.module}/vpn-key.ovpn
  EOT
}

provisioner "local-exec" {
    # This ensures the command only runs when 'terraform destroy' is executed
    when = destroy 
    
    # This command securely deletes the local file regardless of whether it exists.
    command = "rm -f ${path.module}/vpn-key.ovpn"
  }
}




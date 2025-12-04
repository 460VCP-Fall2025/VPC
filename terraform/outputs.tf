#output ssh command for VPN-EC2 upon creation
output "vpn_ec2_ssh_command" {
  description = "SSH command to VPN-EC2"
  value       = "ssh -i vpn-keypair.pem ubuntu@${aws_instance.vpn_ec2.public_ip}"
}

output "vpn_ec2_scp_command" {
  description = "scp command for VPN-EC2 (If .opvn key was not successfully copied automatically)"
  value       = "scp -o StrictHostKeyChecking=no -i ./vpn-keypair.pem ubuntu@${aws_instance.vpn_ec2.public_ip}:/home/ubuntu/openvpn-config/vpn-key.ovpn ${path.module}/vpn-key.ovpn"
}

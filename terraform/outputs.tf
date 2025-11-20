# Copyright (c) HashiCorp, Inc.
# SPDX-License-Identifier: MPL-2.0

output "lb_dns_name" {
  value = aws_lb.app.dns_name
}


#output ssh command for VPN-EC2 upon creation
output "vpn_ec2_ssh_command" {
  description = "SSH command for VPN-EC2"
  value       = "ssh -i vpn-keypair.pem ubuntu@${aws_instance.vpn_ec2.public_ip}"
}

output "vpn_ec2_scp_command" {
  description = "scp command for VPN-EC2"
  value       = "scp -o StrictHostKeyChecking=no -i ./vpn-keypair.pem ubuntu@${aws_instance.vpn_ec2.public_ip}:/home/ubuntu/vpn-key.ovpn ${path.module}/vpn-key.ovpn"
}

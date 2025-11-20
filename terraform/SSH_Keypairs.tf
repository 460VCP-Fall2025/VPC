
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
  content         = tls_private_key.vpn_key.private_key_pem
  filename        = "${path.module}/vpn-keypair.pem"
  file_permission = "0400"
}
